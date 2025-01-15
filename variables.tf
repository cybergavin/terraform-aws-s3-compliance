variable "org" {
  description = "A name or abbreviation for the Organization. Only alphanumeric characters and hyphens are valid, with a string length from 3 to 8 characters."
  type        = string
  default     = "acme-it"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]*(?:-[a-zA-Z0-9]+)*$", var.org)) && length(var.org) >= 3 && length(var.org) <= 8
    error_message = "The variable 'org' accepts only alphanumeric characters and hyphens, with a string length from 3 to 8 characters. The value of var.org must not begin with a hypen and must not contain consecutive hyphens."
  }
}

variable "app_id" {
  description = "The universally unique application ID for the service. Only alphanumeric characters are valid, with a string length from 3 to 8 characters."
  type        = string
  default     = "appid"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{3,8}$", var.app_id))
    error_message = "The variable 'app_id' accepts only alphanumeric characters, with a string length from 3 to 8 characters."
  }
}

variable "global_tags" {
  description = "A map of global tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "A valid Infrastructure Environment"
  type        = string
  default     = "poc"
}

variable "s3_buckets" {
  description = "List of bucket configurations"
  type = list(object({
    name                       = string
    data_classification        = string
    public_access_enabled      = optional(bool)
    versioning_enabled         = optional(bool)
    logging_enabled            = optional(bool)
    kms_master_key_id          = optional(string)
    compliance_standard        = optional(string)
    object_lock_mode           = optional(string)
    object_lock_retention_days = optional(number)
    expiration_days            = optional(number)
    intelligent_tiering_transition_days = optional(number)
    glacier_ir_transition_days    = optional(number)
    glacier_fr_transition_days    = optional(number)
    glacier_da_transition_days   = optional(number)
  }))

  # Validate lifecycle transition days
  validation {
    condition = alltrue([ 
      for bucket in var.s3_buckets : (
        # If any transition days are set, validate the full lifecycle configuration
        anytrue([
          bucket.intelligent_tiering_transition_days != null,
          bucket.glacier_ir_transition_days != null,
          bucket.glacier_fr_transition_days != null,
          bucket.glacier_da_transition_days != null,
          bucket.expiration_days != null
        ]) ? (
          # Validate Glacier-IR > Intelligent-Tiering
          (bucket.glacier_ir_transition_days == null || bucket.intelligent_tiering_transition_days == null || 
            (coalesce(bucket.glacier_ir_transition_days, 0) > coalesce(bucket.intelligent_tiering_transition_days, 0))) &&
          
          # Validate Glacier-FR > Glacier-IR + 90 days
          (bucket.glacier_fr_transition_days == null || bucket.glacier_ir_transition_days == null || 
            (coalesce(bucket.glacier_fr_transition_days, 0) > coalesce(bucket.glacier_ir_transition_days, 0) + 90)) &&
          
          # Validate Glacier-DA > Glacier-FR + 90 days
          (bucket.glacier_da_transition_days == null || bucket.glacier_fr_transition_days == null || 
            (coalesce(bucket.glacier_da_transition_days, 0) > coalesce(bucket.glacier_fr_transition_days, 0) + 90)) &&
          
          # Validate Glacier-DA > Glacier-IR + 90 days (if Glacier-FR is not provided)
          (bucket.glacier_da_transition_days == null || bucket.glacier_ir_transition_days == null || 
            (coalesce(bucket.glacier_da_transition_days, 0) > coalesce(bucket.glacier_ir_transition_days, 0) + 90)) &&
          
          # Validate Expiration > max transition days + 180
          (bucket.expiration_days == null || (coalesce(bucket.expiration_days,0) > max(
            coalesce(bucket.intelligent_tiering_transition_days, 0),
            coalesce(bucket.glacier_ir_transition_days, 0),
            coalesce(bucket.glacier_fr_transition_days, 0),
            coalesce(bucket.glacier_da_transition_days, 0)
          ) + 180))
        ) : true
      )
    ])
  
    error_message = <<EOF
Invalid lifecycle configuration. Requirements:
1) glacier_ir_transition_days must be greater than intelligent_tiering_transition_days.
2) glacier_fr_transition_days must be at least 90 days after glacier_ir_transition_days.
3) glacier_da_transition_days must be at least 90 days after glacier_fr_transition_days (or glacier_ir_transition_days if glacier_fr is not set).
4) expiration_days must be at least 180 days after the latest transition day (intelligent_tiering, glacier_ir, glacier_fr, or glacier_da).
EOF
}

  # Validate bucket names
  validation {
    condition = alltrue([
      for bucket in var.s3_buckets : 
        can(regex("^[a-zA-Z0-9]{3,10}$", bucket.name))
    ])
    error_message = "Bucket names must be 3-10 characters long and contain only alphanumeric characters"
  }

  # Validate object lock mode values
  validation {
    condition = alltrue([
      for bucket in var.s3_buckets :
        bucket.object_lock_mode == null ? true :
        contains(["GOVERNANCE", "COMPLIANCE"], bucket.object_lock_mode)
    ])
    error_message = "object_lock_mode must be either 'GOVERNANCE' or 'COMPLIANCE' when specified"
  }

  # Validate object lock retention days is positive when specified
  validation {
    condition = alltrue([
      for bucket in var.s3_buckets :
        bucket.object_lock_retention_days == null ? true :
        bucket.object_lock_retention_days > 0
    ])
    error_message = "object_lock_retention_days must be greater than 0 when specified"
  }
}

variable "s3_log_retention_days" {
  description = "The number of days to retain S3 logs."
  type        = number
  default     = 1
}