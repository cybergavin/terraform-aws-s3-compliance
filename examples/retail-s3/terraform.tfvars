org         = "cg-it" # Cybergavin IT department
app_id      = "weeat"   # Restaurant Application
environment = "sbx"   # Sandbox

s3_buckets = [
    {
        name = "menus"
        data_classification = "public"
        public_access_enabled = true
    },
    {
        name = "inventory"
        data_classification = "internal"
        intelligent_tiering_transition_days = 30
        logging_enabled = false
    },
    {
        name = "payment"
        data_classification = "compliance"
        compliance_standard = "PCI-DSS"
        glacier_ir_transition_days = 180
        expiration_days = 2555
    }
]

s3_log_retention_days = 5

global_tags = {
  "cg-it:application:name"       = "Restaurant"
  "cg-it:application:id"         = "ueat"
  "cg-it:application:owner"      = "Cybergavin IT"
  "cg-it:operations:environment" = "sbx"
  "cg-it:operations:managed_by"  = "OpenTofu"
  "cg-it:cost:cost_center"       = "CA45321"
  "cg-it:cost:business_unit"     = "ITS"
}