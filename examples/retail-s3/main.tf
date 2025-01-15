module "retail_s3" {
  source = "../../"
  org = var.org
  app_id = var.app_id
  environment = var.environment
  s3_buckets = var.s3_buckets
  s3_log_retention_days = var.s3_log_retention_days
  global_tags = var.global_tags
}

# output "test" {
#   value = module.retail_s3.test
# }

# output "data_classifications" {
#   value = module.retail_s3.data_classifications
# }

# output "compliance_standards" {
#   value = module.retail_s3.compliance_standards
# }