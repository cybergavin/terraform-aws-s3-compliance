#!/bin/bash

# Check if tofu is installed
if ! command -v tofu &> /dev/null; then
    echo "Error: OpenTofu (tofu) is not installed or not in PATH"
    exit 1
fi

# Format staged .tf files
for d in $(git diff --name-only --cached -- "*.tf" | xargs -i dirname {} | uniq)
do
  tofu fmt $d
done