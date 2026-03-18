aks_infra_subscription_id = "8cbc6f36-7c56-4963-9d36-739db5d00b27" # DCD-CFTAPPS-PROD

# Overwrite LD Storage Account for Prod. Other environments will use the defaults provided in variables.tf file

rd_storage_repl_type   = "ZRS"
rd_storage_access_tier = "Hot"

rd_location_storage_access_tier = "Hot"
sku_service_bus                 = "Premium"