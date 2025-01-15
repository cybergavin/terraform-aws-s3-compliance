# OpenTofu Module: `terraform-aws-s3-compliance`

This OpenTofu module simplifies the creation and management of AWS S3 storage by enforcing data classification standards and organizational security policies. This module aims to help teams deploy and configure S3 storage with consistent, compliant settings, ensuring secure and scalable storage infrastructure.

## Key Features
- **S3 Bucket Provisioning with Data Classifications:** Streamlines the setup of S3 buckets with default options based on organizational data classification standards, while allowing for customization of certain settings.
- **Consistent nomenclature:** Leverages the cloudposse `terraform-null-label` module for consistent names for S3 buckets.
- **Policy Enforcement for Security and Compliance:** Enables adherence to security best practices, preventing misconfigurations via input validation.
- **Scalable and Extensible:** Built to integrate with other AWS services, as part of a broader infrastructure, while remaining focused on simplicity and reliability.

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
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
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
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | List of bucket configurations | <pre>list(object({<br/>    name                                = string<br/>    data_classification                 = string<br/>    public_access_enabled               = optional(bool)<br/>    versioning_enabled                  = optional(bool)<br/>    logging_enabled                     = optional(bool)<br/>    kms_master_key_id                   = optional(string)<br/>    compliance_standard                 = optional(string)<br/>    object_lock_mode                    = optional(string)<br/>    object_lock_retention_days          = optional(number)<br/>    expiration_days                     = optional(number)<br/>    intelligent_tiering_transition_days = optional(number)<br/>    glacier_ir_transition_days          = optional(number)<br/>    glacier_fr_transition_days          = optional(number)<br/>    glacier_da_transition_days          = optional(number)<br/>  }))</pre> | n/a | yes |
| <a name="input_s3_log_retention_days"></a> [s3\_log\_retention\_days](#input\_s3\_log\_retention\_days) | The number of days to retain S3 logs. | `number` | `1` | no |

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