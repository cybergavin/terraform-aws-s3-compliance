variable "org" {
  description = "A name or abbreviation for the Organization. Only alphanumeric characters and hyphens are valid, with a string length from 3 to 8 characters."
  type        = string
}

variable "app_id" {
  description = "The universally unique application ID for the service. Only alphanumeric characters are valid, with a string length from 3 to 8 characters."
  type        = string
}

variable "global_tags" {
  description = "A map of global tags to apply to all resources."
  type        = map(string)
}

variable "environment" {
  description = "A valid Infrastructure Environment"
  type        = string
}

variable "s3_buckets" {
  description = "List of bucket configurations"
  type = list(object({
    # Basic configuration
    name                  = string
    data_classification   = string
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
}

variable "s3_logs" {
  description = "Global settings for S3 logs"
  type = object({
    retention_days       = optional(number)
    versioning_enabled   = optional(bool)
    immutability_enabled = optional(bool)
  })
}