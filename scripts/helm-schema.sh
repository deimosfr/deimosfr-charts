#!/bin/bash
set -e

# Verify helm schema plugin is installed
if ! helm schema --help >/dev/null 2>&1; then
    echo "helm schema plugin not found. Installing..."
    helm plugin install https://github.com/losisin/helm-values-schema-json --verify=false
fi

for file in "$@"; do
    echo "Generating schema for $file..."
    helm schema -f "$file"
done
