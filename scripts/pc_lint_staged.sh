#!/bin/bash

# Check if tflint is installed
if ! command -v tflint &> /dev/null; then
    echo "Error: tflint is not installed or not in PATH"
    exit 1
fi

# Initialize TFLint plugins if .tflint.hcl exists
if [ -f ".tflint.hcl" ]; then
    tflint --init
fi

# Lint staged .tf files
for d in $(git diff --name-only --cached -- "*.tf" | xargs -i dirname {} | uniq)
do
  tflint --chdir=$d --recursive
done