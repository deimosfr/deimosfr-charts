#!/bin/bash

# Shared utilities for chart update scripts

# Colored logging
log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1" >&2
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

log_warn() {
    echo -e "\033[0;33m[WARN]\033[0m $1" >&2
}

# Fetch latest tag from GitHub
fetch_latest_github_tag() {
    local owner="$1"
    local repo="$2"
    local tag

    log_info "Fetching latest release for $owner/$repo from GitHub..."
    tag=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [[ -z "$tag" || "$tag" == "null" ]]; then
        log_error "Could not fetch latest tag for $owner/$repo"
        return 1
    fi
    echo "$tag"
}

# Fetch latest tag from Gitea/Forgejo
fetch_latest_gitea_tag() {
    local api_url="$1"
    local tag

    log_info "Fetching latest release from Gitea ($api_url)..."
    # Assuming the API returns a list of releases and we want the first one
    tag=$(curl -s "$api_url/releases?limit=1" | jq -r '.[0].tag_name')

    if [[ -z "$tag" || "$tag" == "null" ]]; then
        log_error "Could not fetch latest tag from $api_url"
        return 1
    fi
    echo "$tag"
}

# Get version from Chart.yaml
get_local_chart_version() {
    local chart_dir="$1"
    local version_file="$chart_dir/Chart.yaml"
    
    if [[ ! -f "$version_file" ]]; then
        echo ""
        return
    fi
    
    grep '^version:' "$version_file" | awk '{print $2}'
}

# Normalize version (remove leading 'v')
normalize_version() {
    local version="$1"
    echo "${version#v}"
}

# Create a temporary directory and ensure cleanup
create_temp_dir() {
    local prefix="$1"
    local temp_dir
    temp_dir="$(pwd)/.tmp_${prefix}_update"
    mkdir -p "$temp_dir"
    echo "$temp_dir"
}

# Update Chart.yaml version and appVersion
update_chart_yaml() {
    local chart_dir="$1"
    local new_version="$2"
    local new_app_version="$3" # Optional, defaults to new_version 
    local version_file="$chart_dir/Chart.yaml"

    if [[ -z "$new_app_version" ]]; then
        new_app_version="$new_version"
    fi

    local norm_version
    norm_version=$(normalize_version "$new_version")

    if [[ -f "$version_file" ]]; then
        log_info "Bumping Chart.yaml version to $norm_version"
        # Update version (always normalized)
        sed -i "s/^version: .*/version: $norm_version/" "$version_file"
        
        # Update appVersion (preserve format if possible, but here we likely want the tag)
        # Note: Some charts use 'v' prefix for appVersion, some don't. 
        # The caller typically passes the raw tag for appVersion.
        sed -i "s/^appVersion: .*/appVersion: \"$new_app_version\"/" "$version_file"
    else
        log_error "Chart.yaml not found at $version_file"
        return 1
    fi
}

# Write to GITHUB_OUTPUT
write_github_output() {
    local version="$1"
    # Normalize for output
    local norm_version
    norm_version=$(normalize_version "$version")

    if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "new_version=$norm_version" >> "$GITHUB_OUTPUT"
        echo "update_performed=true" >> "$GITHUB_OUTPUT"
    fi
}
