locals {
  data_compliance = {
    public = {
      config = {
        public_access_enabled = {
          value = false
          allow_override = true
        }
        versioning_enabled = {
          value = false
          allow_override = true
        }
        logging_enabled = {
          value = false
          allow_override = true
        }
        kms_master_key_id = {
          value = null
          allow_override = true
        }
        object_lock_mode = {
          value = null
          allow_override = true
        }
        object_lock_retention_days = {
          value = 0
          allow_override = true
        }
      }
    }
    internal = {
      config = {
        public_access_enabled = {
          value = false
          allow_override = false
        }
        versioning_enabled = {
          value = true
          allow_override = true
        }
        logging_enabled = {
          value = false
          allow_override = true
        }
        kms_master_key_id = {
          value = "default-internal-key"
          allow_override = true
        }
        object_lock_mode = {
          value = null
          allow_override = true
        }
        object_lock_retention_days = {
          value = 0
          allow_override = true
        }
      }
    }
    compliance = {
      config = {
        public_access_enabled = {
          value = false
          allow_override = false
        }
        versioning_enabled = {
          value = true
          allow_override = false
        }
        logging_enabled = {
          value = true
          allow_override = false
        }
        kms_master_key_id = {
          value = "default-internal-key"
          allow_override = true
        }
        compliance_standard = {
          value = "UNKNOWN"
        }
        object_lock_mode = {
          value = "COMPLIANCE"
          allow_override = false 
        }
        object_lock_retention_days = {
          value = 90
          allow_override = false
        }
      }
    }
  }
}