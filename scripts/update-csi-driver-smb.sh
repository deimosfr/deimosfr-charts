#!/bin/bash
set -e

# Configuration
REPO="kubernetes-csi/csi-driver-smb"
CHART_NAME="csi-driver-smb"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
echo "Fetching latest release from GitHub..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not fetch latest tag."
    exit 1
fi

echo "Latest tag: $LATEST_TAG"

# Check local version
LOCAL_VERSION=""
if [ -f "$TARGET_DIR/Chart.yaml" ]; then
    LOCAL_VERSION=$(grep '^version:' "$TARGET_DIR/Chart.yaml" | awk '{print $2}')
fi

echo "Local version: $LOCAL_VERSION"

# Normalize versions for comparison (remove 'v' prefix if present)
LATEST_VER_NUM="${LATEST_TAG#v}"
LOCAL_VER_NUM="${LOCAL_VERSION#v}"

if [ "$LATEST_VER_NUM" == "$LOCAL_VER_NUM" ]; then
    echo "Version match ($LATEST_VER_NUM). No update needed."
    exit 0
fi

echo "Update needed: $LOCAL_VER_NUM -> $LATEST_VER_NUM"

# Create temp directory
TEMP_DIR="$(pwd)/.tmp_csi_driver_update"
mkdir -p "$TEMP_DIR"
# Ensure we clean up
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Cloning upstream repository..."
git clone --depth 1 --branch "$LATEST_TAG" "https://github.com/$REPO.git" "$TEMP_DIR/repo"

# Determine source path
# Upstream structure: charts/<tag>/csi-driver-smb
SOURCE_PATH="$TEMP_DIR/repo/charts/$LATEST_TAG/$CHART_NAME"

if [ ! -d "$SOURCE_PATH" ]; then
    # Fallback to verify if structure is different (e.g. older versions or different structure)
    echo "Warning: Expected path $SOURCE_PATH does not exist."
    echo "Checking for alternative paths..."
    FOUND_PATH=$(find "$TEMP_DIR/repo/charts" -name "$CHART_NAME" -type d | head -n 1)
    if [ -n "$FOUND_PATH" ]; then
        SOURCE_PATH="$FOUND_PATH"
        echo "Found at: $SOURCE_PATH"
    else
        echo "Error: Could not find chart directory in upstream repo."
        exit 1
    fi
fi

# Update local chart
echo "Updating local chart..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_PATH/"* "$TARGET_DIR/"

echo "Successfully updated $CHART_NAME to $LATEST_TAG"

if [ -n "$GITHUB_OUTPUT" ]; then
    echo "new_version=$LATEST_VER_NUM" >> "$GITHUB_OUTPUT"
    echo "update_performed=true" >> "$GITHUB_OUTPUT"
fi
