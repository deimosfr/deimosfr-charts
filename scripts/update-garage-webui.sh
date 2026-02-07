#!/bin/bash
set -e

# Source shared utilities
source "$(dirname "$0")/lib/update-utils.sh"

# Configuration
REPO_OWNER="khairul169"
REPO_NAME="garage-webui"
CHART_NAME="garage-webui"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
LATEST_TAG=$(fetch_latest_github_tag "$REPO_OWNER" "$REPO_NAME")
log_info "Latest tag: $LATEST_TAG"

# Check local version (if exists)
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

# Update Chart.yaml
update_chart_yaml "$TARGET_DIR" "$LATEST_VER_NUM" "$LATEST_VER_NUM"

log_info "Successfully updated $CHART_NAME to $LATEST_TAG"

# Output for GitHub Actions
write_github_output "$LATEST_VER_NUM"
