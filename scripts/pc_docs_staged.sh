#!/bin/bash

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "Error: terraform-docs is not installed or not in PATH"
    exit 1
fi

# Generate docs only if .tf files in current directory are staged and README.md exists with markers
if git diff --name-only --cached -- "./*.tf" &> /dev/null && \
   [ -f "README.md" ] && \
   grep -q "<!-- BEGIN_TF_DOCS -->" "README.md"; then
    terraform-docs .
fi