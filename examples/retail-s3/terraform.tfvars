org         = "cg-it" # Cybergavin IT department
app_id      = "retail"   # Retail Application
environment = "sbx"   # Sandbox

s3_buckets = [
    {
        name = "menus"
        data_classification = "public"
        public_access_enabled = true
        expiration_days = 365
    },
    {
        name = "invent"
        data_classification = "internal"
        intelligent_tiering_transition_days = 30
        expiration_days = 365
    },
    {
        name = "payment"
        data_classification = "compliance"
        compliance_standard = "PCI-DSS"
        glacier_ir_transition_days = 30
        expiration_days = 365
    }
]

global_tags = {
  "cg-it:application:name"       = "Retail"
  "cg-it:application:id"         = "retail"
  "cg-it:application:owner"      = "Cybergavin IT"
  "cg-it:operations:environment" = "sbx"
  "cg-it:operations:managed_by"  = "OpenTofu"
  "cg-it:cost:cost_center"       = "CA45321"
  "cg-it:cost:business_unit"     = "ITS"
}