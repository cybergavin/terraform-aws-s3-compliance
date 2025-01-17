![](https://github.com/cybergavin/terraform-aws-s3-compliance/actions/workflows/ci.yml/badge.svg)
![](https://github.com/cybergavin/terraform-aws-s3-compliance/actions/workflows/cd.yml/badge.svg)

# OpenTofu Module: `s3-compliance`

This OpenTofu module simplifies the creation and management of AWS S3 buckets by enforcing data classification standards and organizational security policies. This *opinionated* module aims to help teams deploy and configure S3 storage with consistent, **compliant** settings, ensuring secure and scalable storage infrastructure. The compliance settings are embedded in the module (`s3-compliance.tf`). You may view these settings by checking the module's output `compliance_standards`. The default data classifications in the module's compliance settings are `public`, `internal` and `compliance`. You may customize these settings (e.g., rename the data classifications or add more data classifications) by forking this repo and then modifying the embedded `s3-compliance.tf`.  

## Key Features

This module provides a solution for managing AWS S3 buckets with a focus on compliance, security, and lifecycle management. Below are the salient features of this module:

- **Dynamic S3 Bucket Configuration**: Automatically configures S3 buckets based on user-defined settings and compliance requirements.

- **Data Classification Support**: Validates and applies data classification settings to S3 buckets, ensuring compliance with organizational policies.

- **Public Access Management**: Configures public access settings for S3 buckets, allowing for fine-grained control over public access based on compliance requirements.

- **Versioning and Object Locking**: Supports enabling versioning and object locking for S3 buckets, ensuring data immutability and compliance with retention policies.

- **Server-Side Encryption**: Configures server-side encryption for S3 buckets using AWS KMS, enhancing data security and audit.

- **Lifecycle Management**: Supports lifecycle rules for both versioned and unversioned buckets, automating transitions to different storage classes and managing expiration of objects.

- **Centralized Logging**: Supports a centralized S3 bucket for logging CloudTrail events related to S3 data access, ensuring auditability and compliance.

- **Customizable Tags**: Supports tagging of S3 buckets for better resource management and compliance tracking.

- **Consistent Names**: Leverages the `label` terraform module to provision resources with a standardized nomenclature.

- **Error Handling and Validation**: Includes validation checks to ensure that configurations adhere to compliance standards, preventing misconfigurations.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0, >= 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_s3_bucket_label"></a> [storage\_s3\_bucket\_label](#module\_storage\_s3\_bucket\_label) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |
| <a name="module_storage_s3_logging_label"></a> [storage\_s3\_logging\_label](#module\_storage\_s3\_logging\_label) | git::https://github.com/cloudposse/terraform-null-label.git | 488ab91e34a24a86957e397d9f7262ec5925586a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.s3_data_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_s3_bucket.centralized_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.centralized_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.unversioned](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.versioned](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_object_lock_configuration.centralized_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_policy.centralized_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.tls_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.centralized_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.centralized_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.centralized_logs_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | The universally unique application ID for the service. Only alphanumeric characters are valid, with a string length from 3 to 8 characters. | `string` | `"appid"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | A valid Infrastructure Environment | `string` | `"poc"` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | A map of global tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_org"></a> [org](#input\_org) | A name or abbreviation for the Organization. Only alphanumeric characters and hyphens are valid, with a string length from 3 to 8 characters. | `string` | `"acme-it"` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | List of S3 bucket configurations. | <pre>list(object({<br/>    # Basic configuration<br/>    name                  = string<br/>    data_classification   = string # Defaults are "public", "internal" and "compliance"<br/>    public_access_enabled = optional(bool)<br/>    versioning_enabled    = optional(bool)<br/>    logging_enabled       = optional(bool)<br/>    tags                  = optional(map(string), {})<br/><br/>    # Encryption settings<br/>    kms_master_key_id   = optional(string, null) # Use S3-managed keys by default<br/>    compliance_standard = optional(string, null) # e.g., "PCI-DSS", "HIPAA", "ISO27001"<br/><br/>    # Object Lock settings<br/>    object_lock = optional(object({<br/>      mode           = optional(string, null) # "GOVERNANCE" or "COMPLIANCE"<br/>      retention_days = optional(number, null) # Number of days to retain objects in locked state<br/>    }), null)<br/><br/>    # Lifecycle configuration<br/>    lifecycle_transitions = optional(object({<br/>      intelligent_tiering_days = optional(number, null)<br/>      glacier_ir_days          = optional(number, null)<br/>      glacier_fr_days          = optional(number, null)<br/>      glacier_da_days          = optional(number, null)<br/>    }), null)<br/><br/>    expiration_days = optional(number, null) # Expiration after the latest transition<br/>  }))</pre> | n/a | yes |
| <a name="input_s3_logs"></a> [s3\_logs](#input\_s3\_logs) | Global settings for S3 CloudTrail logs | <pre>object({<br/>    retention_days       = optional(number)<br/>    versioning_enabled   = optional(bool)<br/>    immutability_enabled = optional(bool)<br/>  })</pre> | <pre>{<br/>  "immutability_enabled": false,<br/>  "retention_days": 30,<br/>  "versioning_enabled": false<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arns"></a> [bucket\_arns](#output\_bucket\_arns) | Map of bucket names to their ARNs |
| <a name="output_bucket_data_classifications"></a> [bucket\_data\_classifications](#output\_bucket\_data\_classifications) | Map of bucket names to their data classifications |
| <a name="output_bucket_domain_names"></a> [bucket\_domain\_names](#output\_bucket\_domain\_names) | Map of bucket names to their domain names |
| <a name="output_bucket_ids"></a> [bucket\_ids](#output\_bucket\_ids) | Map of bucket names to their IDs |
| <a name="output_bucket_regional_domain_names"></a> [bucket\_regional\_domain\_names](#output\_bucket\_regional\_domain\_names) | Map of bucket names to their regional domain names |
| <a name="output_compliance_standards"></a> [compliance\_standards](#output\_compliance\_standards) | Default security compliance standards for S3 buckets, configured in the module |
| <a name="output_data_classifications"></a> [data\_classifications](#output\_data\_classifications) | List of available data classifications in the module |
<!-- END_TF_DOCS -->