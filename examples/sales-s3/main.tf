# Use the s3-compliance OpenTofu module for a sales application
module "sales-s3" {
  source                       = "../../"
  org                          = var.org
  app_id                       = var.app_id
  environment                  = var.environment
  s3_buckets                   = var.s3_buckets
  s3_logs                      = var.s3_logs
  global_tags                  = var.global_tags
  s3logs_force_destroy_enabled = var.s3logs_force_destroy_enabled # Only used for testing in CI/CD
}

output "data_classifications" {
  description = "Map of data classifications for S3 buckets"
  value       = module.sales-s3.data_classifications
}

output "compliance_standards" {
  description = "Map of security compliance standards for data classifications"
  value       = module.sales-s3.compliance_standards
}

# Enable force_destroy for testing in CI/CD
variable "s3logs_force_destroy_enabled" {
  default     = false
  description = "Enable force_destroy for testing in CI/CD"
  type        = bool
}