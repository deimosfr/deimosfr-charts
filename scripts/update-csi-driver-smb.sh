#!/bin/bash
set -e

# Source shared utilities
source "$(dirname "$0")/lib/update-utils.sh"

# Configuration
REPO="kubernetes-csi/csi-driver-smb"
CHART_NAME="csi-driver-smb"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
# Split REPO into owner and name for the helper
REPO_OWNER="kubernetes-csi"
REPO_NAME="csi-driver-smb"
LATEST_TAG=$(fetch_latest_github_tag "$REPO_OWNER" "$REPO_NAME")
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
TEMP_DIR=$(create_temp_dir "csi_driver")
trap 'rm -rf "$TEMP_DIR"' EXIT

log_info "Cloning upstream repository..."
git clone --depth 1 --branch "$LATEST_TAG" "https://github.com/$REPO.git" "$TEMP_DIR/repo"

# Determine source path
# Upstream structure: charts/<tag>/csi-driver-smb
SOURCE_PATH="$TEMP_DIR/repo/charts/$LATEST_TAG/$CHART_NAME"

if [[ ! -d "$SOURCE_PATH" ]]; then
    # Fallback to verify if structure is different
    log_warn "Expected path $SOURCE_PATH does not exist."
    log_info "Checking for alternative paths..."
    FOUND_PATH=$(find "$TEMP_DIR/repo/charts" -name "$CHART_NAME" -type d | head -n 1)
    if [[ -n "$FOUND_PATH" ]]; then
        SOURCE_PATH="$FOUND_PATH"
        log_info "Found at: $SOURCE_PATH"
    else
        log_error "Could not find chart directory in upstream repo."
        exit 1
    fi
fi

# Update local chart
log_info "Updating local chart..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_PATH/"* "$TARGET_DIR/"

# Disable windows support by default to avoid trivy scanning errors on linux
# The windows image tag has a suffix -windows-hp which causes:
# "remote error: no child with platform linux/amd64"
log_info "Disabling windows support in values.yaml..."
# Use perl for multi-line replacement to target only the windows section
perl -i -pe 'BEGIN{undef $/;} s/windows:\n  enabled: true/windows:\n  enabled: false/smg' "$TARGET_DIR/values.yaml"

log_info "Successfully updated $CHART_NAME to $LATEST_TAG"

# Output for GitHub Actions
write_github_output "$LATEST_VER_NUM"
