# Use the s3-compliance OpenTofu module for a shopping application
module "shop-s3" {
  source                = "../../"
  org                   = var.org
  app_id                = var.app_id
  environment           = var.environment
  s3_buckets            = var.s3_buckets
  s3_log_retention_days = var.s3_log_retention_days
  global_tags           = var.global_tags
}

output "data_classifications" {
  description = "Map of data classifications for S3 buckets"
  value       = module.shop-s3.data_classifications
}

output "compliance_standards" {
  description = "Map of security compliance standards for data classifications"
  value       = module.shop-s3.compliance_standards
}