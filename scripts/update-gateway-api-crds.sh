#!/bin/bash
set -e

# Source shared utilities
source "$(dirname "$0")/lib/update-utils.sh"

# Configuration
REPO="kubernetes-sigs/gateway-api"
CHART_NAME="gateway-api-crds"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
# Split REPO into owner and name for the helper
REPO_OWNER="kubernetes-sigs"
REPO_NAME="gateway-api"
LATEST_TAG=$(fetch_latest_github_tag "$REPO_OWNER" "$REPO_NAME")
log_info "Latest tag: $LATEST_TAG"

# Check local version (appVersion in Chart.yaml corresponds to the upstream version)
# We need to read appVersion, not version, because version is the chart version (0.1.0 etc)
version_file="$TARGET_DIR/Chart.yaml"
if [[ ! -f "$version_file" ]]; then
    log_error "Chart.yaml not found at $version_file"
    exit 1
fi
LOCAL_APP_VERSION=$(grep '^appVersion:' "$version_file" | awk -F'"' '{print $2}')
if [[ -z "$LOCAL_APP_VERSION" ]]; then
     # Try single quotes or no quotes
     LOCAL_APP_VERSION=$(grep '^appVersion:' "$version_file" | awk '{print $2}' | tr -d '"' | tr -d "'")
fi

log_info "Local appVersion: $LOCAL_APP_VERSION"

# Normalize versions for comparison
LATEST_VER_NUM=$(normalize_version "$LATEST_TAG")
LOCAL_VER_NUM=$(normalize_version "$LOCAL_APP_VERSION")

if [[ "$LATEST_VER_NUM" == "$LOCAL_VER_NUM" ]]; then
    log_info "Version match ($LATEST_VER_NUM). No update needed."
    exit 0
fi

log_info "Update needed: $LOCAL_VER_NUM -> $LATEST_VER_NUM"

# Download CRDs
FOLDER="config/crd/standard"
log_info "Fetching CRD list from $REPO/$FOLDER ($LATEST_TAG)..."

# Using GitHub API to list files in directory
FILES=$(curl -s "https://api.github.com/repos/$REPO/contents/$FOLDER?ref=$LATEST_TAG" | jq -r '.[].download_url')

if [[ -z "$FILES" ]]; then
    log_error "No files found in $FOLDER"
    exit 1
fi

TEMPLATES_DIR="$TARGET_DIR/templates"
if [[ ! -d "$TEMPLATES_DIR" ]]; then
    log_info "Creating templates directory..."
    mkdir -p "$TEMPLATES_DIR"
fi

log_info "Downloading CRDs to $TEMPLATES_DIR..."
for file in $FILES; do
    filename=$(basename "$file")
    log_info "Downloading $filename..."
    curl -o "$TEMPLATES_DIR/$filename" -sL "$file"
done

# Update Chart.yaml
# We want to bump the chart version (minor bump for updates) AND update appVersion
CURRENT_CHART_VERSION=$(get_local_chart_version "$TARGET_DIR")
# Simple semantic version bump (patch) - logic could be more complex but this suffices for now or we can just matching upstream version for chart version?
# The user request said "update the chart version as well and update the app version".
# Often for simple wrappers, chart version = upstream version. Or we increment patch.
# Let's try to match upstream version for chart version as well, or at least bump it.
# If current is 0.1.0 and we update to 1.2.0, maybe we should set chart version to 0.2.0 or 1.2.0?
# The user didn't specify strict versioning for Chart version.
# Let's inspect Chart.yaml again. It is 0.1.0 and appVersion 1.16.0.
# If I update appVersion to 1.2.0 (example), I should probably bump Chart version.
# Let's just use the NEW upstream version as the chart version too, or just bump patch of existing if we want to keep them separate.
# However, usually CRD charts match upstream.
# But here existing is 0.1.0. Let's make the chart version equal to the upstream version for simplicity and clarity, OR just bump existing.
# scripts/lib/update-utils.sh `update_chart_yaml` takes `new_version` and `new_app_version`.
# If I pass LATEST_TAG as version, it sets version: 1.2.0 (normalized) and appVersion: 1.2.0.
# That seems appropriate for a CRD chart.

update_chart_yaml "$TARGET_DIR" "$LATEST_TAG" "$LATEST_TAG"

log_info "Successfully updated $CHART_NAME to $LATEST_TAG"

# Output for GitHub Actions
write_github_output "$LATEST_VER_NUM"
