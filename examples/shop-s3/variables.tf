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

variable "s3_log_retention_days" {
  description = "The number of days to retain S3 logs."
  type        = number
}

variable "s3_buckets" {
  description = "List of bucket configurations"
  type = list(object({
    name                                = string
    data_classification                 = string
    public_access_enabled               = optional(bool)
    versioning_enabled                  = optional(bool)
    logging_enabled                     = optional(bool)
    kms_master_key_id                   = optional(string)
    compliance_standard                 = optional(string)
    object_lock_mode                    = optional(string)
    object_lock_retention_days          = optional(number)
    expiration_days                     = optional(number)
    intelligent_tiering_transition_days = optional(number)
    glacier_ir_transition_days          = optional(number)
    glacier_fr_transition_days          = optional(number)
    glacier_da_transition_days          = optional(number)
  }))
}