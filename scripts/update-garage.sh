#!/bin/bash
set -e

# Source shared utilities
source "$(dirname "$0")/lib/update-utils.sh"

# Configuration
REPO_API="https://git.deuxfleurs.fr/api/v1/repos/Deuxfleurs/garage"
REPO_GIT="https://git.deuxfleurs.fr/Deuxfleurs/garage.git"
CHART_NAME="garage"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
LATEST_TAG=$(fetch_latest_gitea_tag "$REPO_API")
log_info "Latest tag: $LATEST_TAG"

# Check local version
LOCAL_VERSION=$(get_local_chart_version "$TARGET_DIR")
log_info "Local version: $LOCAL_VERSION"

# Normalize versions for comparison
LATEST_VER_NUM=$(normalize_version "$LATEST_TAG")
LOCAL_VER_NUM=$(normalize_version "$LOCAL_VERSION")

if ! version_gt "$LATEST_VER_NUM" "$LOCAL_VER_NUM"; then
    log_info "No update needed (Local: $LOCAL_VER_NUM, Remote: $LATEST_VER_NUM)"
    exit 0
fi

log_info "Update needed: $LOCAL_VER_NUM -> $LATEST_VER_NUM"

# Create temp directory
TEMP_DIR=$(create_temp_dir "garage")
trap 'rm -rf "$TEMP_DIR"' EXIT

log_info "Cloning upstream repository..."
# Gitea supports shallow clones
git clone --depth 1 --branch "$LATEST_TAG" "$REPO_GIT" "$TEMP_DIR/repo"

# Source path in upstream repo
SOURCE_PATH="$TEMP_DIR/repo/script/helm/garage"

if [[ ! -d "$SOURCE_PATH" ]]; then
    log_error "Chart directory $SOURCE_PATH does not exist in upstream."
    exit 1
fi

# Update local chart
log_info "Updating local chart..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_PATH/"* "$TARGET_DIR/"

# Update Chart.yaml version (to match release tag and avoid infinite updates)
# Pass LATEST_TAG as appVersion
update_chart_yaml "$TARGET_DIR" "$LATEST_VER_NUM" "$LATEST_TAG"

log_info "Successfully updated $CHART_NAME to $LATEST_TAG"

# Output for GitHub Actions
write_github_output "$LATEST_VER_NUM"
