# Data Source for AWS regions
data "aws_region" "current" {}

# Data Source for AWS availability zones
data "aws_availability_zones" "current" {}

# Local variables
locals {
  # Retrieve region details - this breaks for regions like Asia-Pacific
  region_name_parts = split("-", data.aws_region.current.name)
  region_code       = "${local.region_name_parts[0]}${join("", [for i in range(1, length(local.region_name_parts)) : substr(local.region_name_parts[i], 0, 1)])}"
  
  # Create a map of S3 buckets with their standardized names (labels.tf) as keys
  s3_buckets_map = { 
    for bucket in var.s3_buckets : 
    module.storage_s3_bucket_label[bucket.name].id => bucket
    if contains(keys(local.data_compliance), bucket.data_classification)
    }
  
  # Validate and merge user settings with compliance configuration
  validated_bucket_configs = {
    for name, bucket in local.s3_buckets_map : name => {
      # Set data classification
      data_classification = bucket.data_classification
       

      # Validate and merge settings
      public_access_enabled = (
        !local.data_compliance[bucket.data_classification].config.public_access_enabled.allow_override && 
        bucket.public_access_enabled != local.data_compliance[bucket.data_classification].config.public_access_enabled.value ? 
        local.data_compliance[bucket.data_classification].config.public_access_enabled.value : 
        coalesce(bucket.public_access_enabled, local.data_compliance[bucket.data_classification].config.public_access_enabled.value)
      )

      # Validate and set versioning
      versioning_enabled = (
        !local.data_compliance[bucket.data_classification].config.versioning_enabled.allow_override && 
        bucket.versioning_enabled != local.data_compliance[bucket.data_classification].config.versioning_enabled.value ? 
        local.data_compliance[bucket.data_classification].config.versioning_enabled.value :
        coalesce(bucket.versioning_enabled, local.data_compliance[bucket.data_classification].config.versioning_enabled.value)
      )

      # Validate and set logging
      logging_enabled = (
        !local.data_compliance[bucket.data_classification].config.logging_enabled.allow_override && 
        bucket.logging_enabled != local.data_compliance[bucket.data_classification].config.logging_enabled.value ? 
        local.data_compliance[bucket.data_classification].config.logging_enabled.value :
        coalesce(bucket.logging_enabled, local.data_compliance[bucket.data_classification].config.logging_enabled.value)
      )

      # Validate and set KMS
      kms_master_key_id = (
        bucket.kms_master_key_id == null && local.data_compliance[bucket.data_classification].config.kms_master_key_id.value == null ? null : (
          !local.data_compliance[bucket.data_classification].config.kms_master_key_id.allow_override && 
          bucket.kms_master_key_id != null ? 
          local.data_compliance[bucket.data_classification].config.kms_master_key_id.value :
          coalesce(bucket.kms_master_key_id, local.data_compliance[bucket.data_classification].config.kms_master_key_id.value)
        )
      )
    
      # Set compliance standard
      compliance_standard = (
        !contains(keys(local.data_compliance[bucket.data_classification].config), "compliance_standard") ? null :
        coalesce(bucket.compliance_standard, local.data_compliance[bucket.data_classification].config.compliance_standard.value)
      )
    
      # Validate and set object lock mode
      object_lock_mode = (
        bucket.object_lock_mode == null && local.data_compliance[bucket.data_classification].config.object_lock_mode.value == null ? null : (
          local.data_compliance[bucket.data_classification].config.object_lock_mode.allow_override ? 
          coalesce(bucket.object_lock_mode, local.data_compliance[bucket.data_classification].config.object_lock_mode.value) :
          local.data_compliance[bucket.data_classification].config.object_lock_mode.value
        )
      )
    
      # Validate and set object lock retention days
      object_lock_retention_days = (
        bucket.object_lock_retention_days == null && local.data_compliance[bucket.data_classification].config.object_lock_retention_days.value == null ? null : (
          local.data_compliance[bucket.data_classification].config.object_lock_retention_days.allow_override ? 
          coalesce(bucket.object_lock_retention_days, local.data_compliance[bucket.data_classification].config.object_lock_retention_days.value) :
          local.data_compliance[bucket.data_classification].config.object_lock_retention_days.value
        )
      )

      # Validate and set intelligent tiering transition days
      intelligent_tiering_transition_days = (
        bucket.intelligent_tiering_transition_days == null ? null : bucket.intelligent_tiering_transition_days
      )

      # Validate and set Glacier Instant Retrieval transition days 
      glacier_ir_transition_days = (
        bucket.glacier_ir_transition_days == null ? null : bucket.glacier_ir_transition_days
      )

      # Validate and set Glacier Flexible Retrieval transition days
      glacier_fr_transition_days = (
        bucket.glacier_fr_transition_days == null ? null : bucket.glacier_fr_transition_days
      )

      # Validate and set Glacier Deep Archive transition days
      glacier_da_transition_days = (
        bucket.glacier_da_transition_days == null ? null : bucket.glacier_da_transition_days
      )

      # Validate and set expiration days
      expiration_days = (
        bucket.expiration_days == null ? null : bucket.expiration_days
      )
     
    }
  }
}

# Create base S3 buckets
resource "aws_s3_bucket" "this" {
  for_each = local.validated_bucket_configs

  bucket        = each.key
  force_destroy = false

  tags = each.value.compliance_standard != null ? merge(var.global_tags, 
    {
      "${var.org}:security:data_classification" = each.value.data_classification
      "${var.org}:security:compliance" = each.value.compliance_standard != null ? "${each.value.compliance_standard}:${each.value.object_lock_mode}:${each.value.object_lock_retention_days}" : null
    }) : merge(var.global_tags, 
    {
      "${var.org}:security:data_classification" = each.value.data_classification
    })
}

# Configure versioning - must be enabled before object lock
resource "aws_s3_bucket_versioning" "this" {
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if v.versioning_enabled
  }

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure object lock rules - depends on versioning
resource "aws_s3_bucket_object_lock_configuration" "this" {
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if v.object_lock_mode != null
  }

  # Explicit dependency on versioning being enabled
  depends_on = [aws_s3_bucket_versioning.this]

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    default_retention {
      mode = each.value.object_lock_mode
      days = each.value.object_lock_retention_days
    }
  }
}

# Configure server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if v.kms_master_key_id != null
  }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = each.value.kms_master_key_id == "default-internal-key" ? null : each.value.kms_master_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

# Configure public access block
resource "aws_s3_bucket_public_access_block" "this" {
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if v.public_access_enabled
  }

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = !each.value.public_access_enabled
  block_public_policy     = !each.value.public_access_enabled
  ignore_public_acls      = !each.value.public_access_enabled
  restrict_public_buckets = !each.value.public_access_enabled
}

# Configure bucket policy for public access
resource "aws_s3_bucket_policy" "this" {
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if v.public_access_enabled
  }

  bucket = aws_s3_bucket.this[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.this[each.key].arn}/*"
      }
    ]
  })
}


# Configure lifecycle rules for unversioned buckets
resource "aws_s3_bucket_lifecycle_configuration" "unversioned" {
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if anytrue([
      v.intelligent_tiering_transition_days != null,
      v.glacier_ir_transition_days != null,
      v.glacier_fr_transition_days != null,
      v.glacier_da_transition_days != null,
      v.expiration_days != null
    ]) && !v.versioning_enabled
  }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    id     = "lifecycle-rule"
    status = "Enabled"

    dynamic "transition" {
      for_each = each.value.intelligent_tiering_transition_days != null ? [1] : []
      content {
        days          = each.value.intelligent_tiering_transition_days
        storage_class = "INTELLIGENT_TIERING"
      }
    }

    dynamic "transition" {
      for_each = each.value.glacier_ir_transition_days != null ? [1] : []
      content {
        days          = each.value.glacier_ir_transition_days
        storage_class = "GLACIER_IR"
      }
    }

    dynamic "transition" {
      for_each = each.value.glacier_fr_transition_days != null ? [1] : []
      content {
        days          = each.value.glacier_fr_transition_days
        storage_class = "GLACIER"
      }
    }

    dynamic "transition" {
      for_each = each.value.glacier_da_transition_days != null ? [1] : []
      content {
        days          = each.value.glacier_da_transition_days
        storage_class = "DEEP_ARCHIVE"
      }
    }

    dynamic "expiration" {
      for_each = each.value.expiration_days != null ? [1] : []
      content {
        days = each.value.expiration_days
      }
    }
  }
}

# Configure lifecycle rules for versioned buckets
resource "aws_s3_bucket_lifecycle_configuration" "versioned" {
  depends_on = [aws_s3_bucket_versioning.this]
  for_each = {
    for k, v in local.validated_bucket_configs : k => v
    if anytrue([
      v.intelligent_tiering_transition_days != null,
      v.glacier_ir_transition_days != null,
      v.glacier_fr_transition_days != null,
      v.glacier_da_transition_days != null,
      v.expiration_days != null
    ]) && v.versioning_enabled
  }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    id     = "lifecycle-rule"
    status = "Enabled"

    dynamic "transition" {
      for_each = each.value.intelligent_tiering_transition_days != null ? [1] : []
      content {
        days          = each.value.intelligent_tiering_transition_days
        storage_class = "INTELLIGENT_TIERING"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = each.value.intelligent_tiering_transition_days != null ? [1] : []
      content {
        noncurrent_days = each.value.intelligent_tiering_transition_days
        storage_class = "INTELLIGENT_TIERING"
      }
    }

    dynamic "transition" {
      for_each = each.value.glacier_ir_transition_days != null ? [1] : []
      content {
        days          = each.value.glacier_ir_transition_days
        storage_class = "GLACIER_IR"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = each.value.glacier_ir_transition_days != null ? [1] : []
      content {
        noncurrent_days = each.value.glacier_ir_transition_days
        storage_class = "GLACIER_IR"
      }
    }

    dynamic "transition" {
      for_each = each.value.glacier_fr_transition_days != null ? [1] : []
      content {
        days          = each.value.glacier_fr_transition_days
        storage_class = "GLACIER"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = each.value.glacier_fr_transition_days != null ? [1] : []
      content {
        noncurrent_days = each.value.glacier_fr_transition_days
        storage_class = "GLACIER"
      }
    }

    dynamic "transition" {
      for_each = each.value.glacier_da_transition_days != null ? [1] : []
      content {
        days          = each.value.glacier_da_transition_days
        storage_class = "DEEP_ARCHIVE"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = each.value.glacier_da_transition_days != null ? [1] : []
      content {
        noncurrent_days = each.value.glacier_da_transition_days
        storage_class = "DEEP_ARCHIVE"
      }
    }

    dynamic "expiration" {
      for_each = each.value.expiration_days != null ? [1] : []
      content {
        days = each.value.expiration_days
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = each.value.expiration_days != null ? [1] : []
      content {
        noncurrent_days = each.value.expiration_days
      }
    }
  }
}

# # Configure bucket logging
# resource "aws_s3_bucket_logging" "this" {
#   for_each = {
#     for k, v in local.validated_bucket_configs : k => v
#     if v.logging_enabled
#   }

#   bucket = aws_s3_bucket.this[each.key].id

#   target_bucket = aws_s3_bucket.this[each.key].id
#   target_prefix = "logs/"
# }