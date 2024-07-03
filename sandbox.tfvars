aks_infra_subscription_id = "b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb" # DCD-CFTAPPS-SBOX

# Overwrite LD Storage Account for Sandbox. Other environments will use the defaults provided in variables.tf file
rd_storage_repl_type    = "LRS"
rd_storage_access_tier  = "Hot"
rd_storage_account_kind = "StorageV1"