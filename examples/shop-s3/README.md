# Shopping Application's S3 Buckets

This example demonstrates how to provision an S3 bucket and DynamoDB table for compliance purposes in the `shop` AWS account, using the `s3-compliance` OpenTofu module. The example illustrates how to set up the necessary resources across multiple environments. A sandbox (`sbx`) environment is provided as an example.

## Prerequisites

- Ensure that you have the necessary permissions to create S3 buckets and DynamoDB tables in your AWS account.

## Usage

The following steps explain how to use the example to provision the S3 bucket and DynamoDB table using the `s3-compliance` module. On the machine where you will execute the OpenTofu commands, do the following:
  - [Install OpenTofu](https://opentofu.org/docs/install/index.html)
  - Set environment variables for the `shop` AWS account. The credentials must be associated with the required permissions to create the resources.
  ```
  export AWS_ACCESS_KEY_ID="your_access_key"
  export AWS_SECRET_ACCESS_KEY="your_secret_key"
  export AWS_REGION="your_region"
  ```
  - Clone the `terraform-aws-s3-compliance` repository.
  ```
  git clone https://github.com/cybergavin/terraform-aws-s3-compliance.git
  ```
  - Set up remote backend: The `shop-s3` example uses OpenTofu's **[early variable evaluation](https://opentofu.org/docs/intro/whats-new/#early-variablelocals-evaluation)** feature to configure the remote backend (S3 buckets and DynamoDB tables) in `backend.tf`. In order to create the remote backend for use by OpenTofu to manage state, a bootstrap script is provided in the `bootstrap` directory. This bootstrap script uses a CloudFormation stack (`bootstrap-backend.yml`) to create the S3 bucket and DynamoDB table. Do the following to bootstrap the backend.
  
    - Execute the following commands:
    ```
    cd examples/shop-s3/bootstrap
    ./bootstrap.sh <ENVIRONMENT>
    ```
    where `<ENVIRONMENT>` is the name of the environment you are bootstrapping (the directory within `environments` directory containing the `terraform.tfvars` file). In this example, a `sbx` (sandbox) environment is used and so the command will be `./bootstrap.sh sbx`.

  - Update the relevant environment's `terraform.tfvars` file with the required variables (or leave as is, if there's no conflict with the default values). In this example, a `sbx` (sandbox) environment is used and so `environments/sbx/terraform.tfvars` is updated.

  - Execute the following OpenTofu commands within the `examples/shop-s3` directory.
  ```
  tofu init --var-file=environments/sbx/terraform.tfvars
  tofu plan --var-file=environments/sbx/terraform.tfvars
  tofu apply --var-file=environments/sbx/terraform.tfvars
  ```
  - If you want to destroy the resources, run the following command.
  ```
  tofu destroy --var-file=environments/sbx/terraform.tfvars
  ```