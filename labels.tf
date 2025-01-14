module "storage_s3_bucket_label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash for v0.25.0

  for_each = { for bucket in var.s3_buckets : bucket.name => bucket }

  tenant      = var.org
  name        = "s3"
  namespace   = format("%s-%s", var.app_id, each.key)
  environment = var.environment
  attributes  = [local.region_code]
  label_order = ["tenant", "name", "namespace", "environment", "attributes"]
}

module "storage_s3_logging_label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # commit hash for v0.25.0

  tenant      = var.org
  name        = "s3"
  namespace   = format("%s-%s", var.app_id, "cloudtrail-logs")
  environment = var.environment
  attributes  = [local.region_code]
  label_order = ["tenant", "name", "namespace", "environment", "attributes"]
}