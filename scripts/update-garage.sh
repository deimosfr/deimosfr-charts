#!/bin/bash
set -e

# Configuration
REPO_API="https://git.deuxfleurs.fr/api/v1/repos/Deuxfleurs/garage"
REPO_GIT="https://git.deuxfleurs.fr/Deuxfleurs/garage.git"
CHART_NAME="garage"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
echo "Fetching latest release from Gitea..."
# Using jq to reliably parse JSON from Gitea/Forgejo API
LATEST_TAG=$(curl -s "$REPO_API/releases?limit=1" | jq -r '.[0].tag_name')

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
    echo "Error: Could not fetch latest tag."
    exit 1
fi

echo "Latest tag: $LATEST_TAG"

# Check local version (if exists)
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
TEMP_DIR="$(pwd)/.tmp_garage_update"
mkdir -p "$TEMP_DIR"
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Cloning upstream repository..."
# Gitea supports shallow clones
git clone --depth 1 --branch "$LATEST_TAG" "$REPO_GIT" "$TEMP_DIR/repo"

# Source path in upstream repo
SOURCE_PATH="$TEMP_DIR/repo/script/helm/garage"

if [ ! -d "$SOURCE_PATH" ]; then
    echo "Error: Chart directory $SOURCE_PATH does not exist in upstream."
    exit 1
fi

# Update local chart
echo "Updating local chart..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_PATH/"* "$TARGET_DIR/"

# Update Chart.yaml version to match the release tag to avoid infinite updates
if [ -f "$TARGET_DIR/Chart.yaml" ]; then
    echo "Bumping Chart.yaml version to $LATEST_VER_NUM"
    # Update version: 0.7.3 -> <latest_tag>
    sed -i "s/^version: .*/version: $LATEST_VER_NUM/" "$TARGET_DIR/Chart.yaml"
    # Ensure appVersion is also correct (though it seems correct in upstream)
    sed -i "s/^appVersion: .*/appVersion: \"$LATEST_TAG\"/" "$TARGET_DIR/Chart.yaml"
fi

echo "Successfully updated $CHART_NAME to $LATEST_TAG"

if [ -n "$GITHUB_OUTPUT" ]; then
    echo "new_version=$LATEST_VER_NUM" >> "$GITHUB_OUTPUT"
    echo "update_performed=true" >> "$GITHUB_OUTPUT"
fi
