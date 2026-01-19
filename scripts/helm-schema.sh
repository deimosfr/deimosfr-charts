#!/bin/bash
set -e

# Verify helm schema plugin is working
if ! helm plugin list | grep -q "schema"; then
    echo "helm schema plugin not found. Installing..."
    helm plugin install https://github.com/losisin/helm-values-schema-json --verify=false
fi

# Double check if binary exists/works by checking help
if ! helm schema --help >/dev/null 2>&1; then
    echo "helm schema command failing. Reinstalling..."
    helm plugin uninstall schema || true
    helm plugin uninstall schema-gen || true # Cleanup the other one if present
    helm plugin install https://github.com/losisin/helm-values-schema-json --verify=false
fi

for file in "$@"; do
    dir=$(dirname "$file")
    echo "Generating schema for $file..."
    # helm schema plugin creates values.schema.json in the same directory by default
    # checking usage: helm schema -f values.yaml
    if helm schema -f "$file" -o "$dir/values.schema.json"; then
         echo "Schema generated for $file"
    else
        echo "Failed to generate schema for $file"
        exit 1
    fi
done
