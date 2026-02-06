#!/bin/bash
set -e

# Configuration
REPO_OWNER="khairul169"
REPO_NAME="garage-webui"
CHART_NAME="garage-webui"
TARGET_DIR="charts/$CHART_NAME"

# Get latest release tag
echo "Fetching latest release from GitHub..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" | jq -r '.tag_name')

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

# Update Chart.yaml version
if [ -f "$TARGET_DIR/Chart.yaml" ]; then
    echo "Bumping Chart.yaml version to $LATEST_VER_NUM"
    # Update version
    sed -i "s/^version: .*/version: $LATEST_VER_NUM/" "$TARGET_DIR/Chart.yaml"
    # Update appVersion
    sed -i "s/^appVersion: .*/appVersion: \"$LATEST_VER_NUM\"/" "$TARGET_DIR/Chart.yaml"
fi

echo "Successfully updated $CHART_NAME to $LATEST_TAG"

if [ -n "$GITHUB_OUTPUT" ]; then
    echo "new_version=$LATEST_VER_NUM" >> "$GITHUB_OUTPUT"
    echo "update_performed=true" >> "$GITHUB_OUTPUT"
fi
