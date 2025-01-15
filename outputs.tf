output "data_classifications" {
  description = "List of available data classifications in the module"
  value       = keys(local.data_compliance)
}

output "compliance_standards" {
  description = "Default security compliance standards for S3 buckets, configured in the module"
  value       = local.data_compliance
}

output "bucket_ids" {
  description = "Map of bucket names to their IDs"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "bucket_arns" {
  description = "Map of bucket names to their ARNs"
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}

output "bucket_data_classifications" {
  description = "Map of bucket names to their data classifications"
  value       = { for k, v in local.s3_buckets_map : k => v.data_classification }
}

output "bucket_domain_names" {
  description = "Map of bucket names to their domain names"
  value       = { for k, v in aws_s3_bucket.this : k => v.bucket_domain_name }
}

output "bucket_regional_domain_names" {
  description = "Map of bucket names to their regional domain names"
  value       = { for k, v in aws_s3_bucket.this : k => v.bucket_regional_domain_name }
}