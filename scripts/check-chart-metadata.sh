#!/bin/bash
set -e

# Find all Chart.yaml files
charts=$(find charts -name Chart.yaml)
failed=0

for chart in $charts; do
    echo "Checking $chart..."
    
    # Check for icon
    if ! grep -q "^icon:" "$chart"; then
        echo "Error: $chart is missing 'icon'."
        failed=1
    fi

    # Check for Verified Publisher annotations
    if ! grep -q "artifacthub.io/changes:" "$chart"; then
        echo "Error: $chart is missing 'artifacthub.io/changes' annotation."
        failed=1
    fi
    if ! grep -q "artifacthub.io/images:" "$chart"; then
        echo "Error: $chart is missing 'artifacthub.io/images' annotation."
        failed=1
    fi
     if ! grep -q "artifacthub.io/category:" "$chart"; then
        echo "Error: $chart is missing 'artifacthub.io/category' annotation."
        failed=1
    fi
done

if [ $failed -eq 1 ]; then
    echo "Metadata checks failed."
    exit 1
fi

echo "All metadata checks passed."
exit 0
