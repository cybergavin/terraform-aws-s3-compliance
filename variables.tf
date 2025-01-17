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
  description = "List of S3 bucket configurations."
  type = list(object({
    # Basic configuration
    name                  = string
    data_classification   = string # Defaults are "public", "internal" and "compliance"
    public_access_enabled = optional(bool, false)
    versioning_enabled    = optional(bool)
    logging_enabled       = optional(bool)
    tags                  = optional(map(string), {})

    # Encryption settings
    kms_master_key_id   = optional(string, null) # Use S3-managed keys by default
    compliance_standard = optional(string, null) # e.g., "PCI-DSS", "HIPAA", "ISO27001"

    # Object Lock settings
    object_lock = optional(object({
      mode           = optional(string, null) # "GOVERNANCE" or "COMPLIANCE"
      retention_days = optional(number, null) # Number of days to retain objects in locked state
    }), null)

    # Lifecycle configuration
    lifecycle_transitions = optional(object({
      intelligent_tiering_days = optional(number, null)
      glacier_ir_days          = optional(number, null)
      glacier_fr_days          = optional(number, null)
      glacier_da_days          = optional(number, null)
    }), null)

    expiration_days = optional(number, null) # Expiration after the latest transition
  }))

  ### Validation Rules

  # Validation rules for s3_buckets
  validation {
    condition = alltrue(flatten([
      # Ensure that retention_days is set only if object_lock.mode is specified
      [for bucket in var.s3_buckets :
        bucket.object_lock == null ||
        try(bucket.object_lock.mode != null && bucket.object_lock.retention_days != null, true)
      ],

      # Ensure that transition days are non-negative
      [for bucket in var.s3_buckets :
        bucket.lifecycle_transitions == null ||
        (
          try(bucket.lifecycle_transitions.intelligent_tiering_days == null, true) ||
          try(bucket.lifecycle_transitions.intelligent_tiering_days >= 0, false)
        ) &&
        (
          try(bucket.lifecycle_transitions.glacier_ir_days == null, true) ||
          try(bucket.lifecycle_transitions.glacier_ir_days >= 0, false)
        ) &&
        (
          try(bucket.lifecycle_transitions.glacier_fr_days == null, true) ||
          try(bucket.lifecycle_transitions.glacier_fr_days >= 0, false)
        ) &&
        (
          try(bucket.lifecycle_transitions.glacier_da_days == null, true) ||
          try(bucket.lifecycle_transitions.glacier_da_days >= 0, false)
        )
      ],

      # Ensure expiration_days is at least 90 days more than Glacier IR and FR days
      [for bucket in var.s3_buckets :
        bucket.expiration_days == null ||
        bucket.lifecycle_transitions == null ||
        (
          try(bucket.lifecycle_transitions.glacier_ir_days == null, true) ||
          try(bucket.expiration_days >= bucket.lifecycle_transitions.glacier_ir_days + 90, false)
        ) &&
        (
          try(bucket.lifecycle_transitions.glacier_fr_days == null, true) ||
          try(bucket.expiration_days >= bucket.lifecycle_transitions.glacier_fr_days + 90, false)
        )
      ],

      # Ensure expiration_days is at least 180 days more than Glacier Deep Archive days
      [for bucket in var.s3_buckets :
        bucket.expiration_days == null ||
        bucket.lifecycle_transitions == null ||
        try(bucket.lifecycle_transitions.glacier_da_days == null, true) ||
        try(bucket.expiration_days >= bucket.lifecycle_transitions.glacier_da_days + 180, false)
      ]
    ]))

    error_message = <<EOF
Invalid lifecycle configuration. Requirements:
1) Object lock retention days can only be set when object lock mode is specified
2) All transition days must be non-negative numbers when specified
3) Expiration days must be at least 90 days after Glacier IR and FR transitions
4) Expiration days must be at least 180 days after Glacier Deep Archive transition
EOF
  }




  # Validate bucket names
  validation {
    condition = alltrue([
      for bucket in var.s3_buckets :
      can(regex("^[a-zA-Z0-9]{3,10}$", bucket.name))
    ])
    error_message = "Bucket names must be 3-10 characters long and contain only alphanumeric characters."
  }

  # Validate object lock mode
  validation {
    condition = alltrue([
      for bucket in var.s3_buckets :
      bucket.object_lock == null ||
      try(bucket.object_lock.mode == null || contains(["GOVERNANCE", "COMPLIANCE"], bucket.object_lock.mode), true)
    ])
    error_message = "Object lock mode must be either 'GOVERNANCE' or 'COMPLIANCE' when specified."
  }

  # Validate object lock retention days
  validation {
    condition = alltrue([
      for bucket in var.s3_buckets :
      bucket.object_lock == null ||
      try(
        bucket.object_lock.retention_days == null ||
        (bucket.object_lock.retention_days >= 1 && bucket.object_lock.retention_days <= 36500),
        true
      )
    ])
    error_message = "Object lock retention days must be between 1 and 36500 days (100 years) when specified."
  }

  validation {
    condition = alltrue([
      for bucket in var.s3_buckets :
      bucket.object_lock == null ||
      try(
        bucket.object_lock.mode != null &&
        contains(["GOVERNANCE", "COMPLIANCE"], bucket.object_lock.mode) &&
        (bucket.object_lock.retention_days == null || bucket.object_lock.retention_days > 0),
        true
      )
    ])
    error_message = "When object_lock is specified: mode must be 'GOVERNANCE' or 'COMPLIANCE', and retention_days (if specified) must be greater than 0."
  }
}

variable "s3_logs" {
  description = "Global settings for S3 CloudTrail logs"
  type = object({
    retention_days       = optional(number)
    versioning_enabled   = optional(bool)
    immutability_enabled = optional(bool)
  })
  default = {
    retention_days       = 30
    versioning_enabled   = false
    immutability_enabled = false # Immutability can only be enabled when versioning is enabled
  }
  validation {
    condition     = coalesce(var.s3_logs.retention_days, 30) > 0
    error_message = "S3 log retention days must be greater than 0."
  }
  validation {
    condition = !(
      coalesce(var.s3_logs.immutability_enabled, false) &&
      !coalesce(var.s3_logs.versioning_enabled, false)
    )
    error_message = "Immutability can only be enabled when versioning is enabled."
  }
}