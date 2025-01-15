org         = "cg-it" # Cybergavin IT department
app_id      = "ecomm"   # Ecommerce Application
environment = "sbx"   # Sandbox

s3_buckets = [
    {
        name = "catalogs"
        data_classification = "public"
        public_access_enabled = true
        tags = {
            "cg-it:application:description" = "Ecommerce application catalogs"
        }
    },
    {
        name = "inventory"
        data_classification = "internal"
        intelligent_tiering_transition_days = 30
    },
    {
        name = "payment"
        data_classification = "compliance"
        compliance_standard = "PCI-DSS"
        glacier_ir_transition_days = 180
        expiration_days = 2555
    }
]

# Set the log retention days for the S3 buckets. Logs are immutable during this period.
s3_log_retention_days = 2

global_tags = {
  "cg-it:application:name"       = "Ecommerce"
  "cg-it:application:id"         = "ecomm"
  "cg-it:application:owner"      = "Cybergavin IT"
  "cg-it:operations:environment" = "sbx"
  "cg-it:operations:managed_by"  = "OpenTofu"
  "cg-it:cost:cost_center"       = "CA45321"
  "cg-it:cost:business_unit"     = "ITS"
}