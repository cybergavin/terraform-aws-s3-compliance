#!/bin/bash

# Check for input ENVIRONMENT argument
if [ -z "$1" ]; then
  echo "Usage: $0 <ENVIRONMENT>"
  exit 1
fi

ENVIRONMENT=$1

# Path to terraform.tfvars file
TFVARS_FILE="../environments/${ENVIRONMENT}/terraform.tfvars"

# Read terraform.tfvars and remove spaces around the '=' and ignore comments
if [ -f "$TFVARS_FILE" ]; then
  while IFS='=' read -r key value; do
    # Skip lines that are comments or empty
    if [[ "$key" =~ ^#.* ]] || [[ -z "$key" ]]; then
      continue
    fi

    # Remove inline comments by cutting everything after the '#'
    value=$(echo "$value" | sed 's/#.*//')

    # Remove any leading/trailing spaces from key and value
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    # Check for keys you're interested in
    case $key in
      org)
        ORG="$value"
        ;;
      app_id)
        APP_ID="$value"
        ;;
      *)
        ;;
    esac
  done < "$TFVARS_FILE"

  # Output the extracted variables
  echo "org: $ORG"
  echo "app_id: $APP_ID"
  echo "environment: $ENVIRONMENT"

  # Deploy the backend cloudformation stack
  aws cloudformation deploy \
    --template-file bootstrap-backend.yml \
    --stack-name "${ORG}-cf-${APP_ID}-${ENVIRONMENT}-tfstate" \
    --parameter-overrides Org="$ORG" AppId="$APP_ID" Environment="$ENVIRONMENT"
else
  echo "Error: $TFVARS_FILE not found."
  exit 1
fi