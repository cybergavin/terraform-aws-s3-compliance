org         = "cg-it" # Cybergavin IT department
app_id      = "sales"   # Sales Application
environment = "sbx"   # Sandbox

s3_buckets = [
    {
        name = "catalogs"
        data_classification = "public"
        public_access_enabled = true
        tags = {
            "cg-it:application:description" = "Sales product catalogs"
        }
    },
    {
        name = "inventory"
        data_classification = "internal"
        tags = {
            "cg-it:application:description" = "Sales inventory"
        }
        lifecycle_transitions = {
            intelligent_tiering_days = 180
        }
        expiration_days = 730
    },
    {
        name = "payment"
        data_classification = "compliance"
        compliance_standard = "PCI-DSS"
        tags = {
            "cg-it:application:description" = "Sales payment transactions"
        }
        lifecycle_transitions = {
            intelligent_tiering_days = 180
            glacier_ir_days = 365
            glacier_fr_days = 730
        }
        expiration_days = 2555
    }
]

s3_logs = {
    retention_days = 30
    immutability_enabled = false
}

global_tags = {
  "cg-it:application:name"       = "Sales"
  "cg-it:application:id"         = "sales"
  "cg-it:application:owner"      = "Cybergavin IT"
  "cg-it:operations:environment" = "sbx"
  "cg-it:operations:managed_by"  = "OpenTofu"
  "cg-it:cost:cost_center"       = "CA45321"
  "cg-it:cost:business_unit"     = "ITS"
}