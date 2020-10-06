aks_infra_subscription_id  = "8cbc6f36-7c56-4963-9d36-739db5d00b27" # DCD-CFTAPPS-PROD
managed_identity_object_id = "1694076c-23bd-40c8-9c9b-64985890d82f"

# Overwrite LD Location Storage Account for AAT & Prod. Other environments will use the defaults provided in variables.tf file
ld_location_storage_repl_type   = "ZRS"
ld_location_storage_access_tier = "Hot"