aks_infra_subscription_id  = "96c274ce-846d-4e48-89a7-d528432298a7" # DCD-CFTAPPS-STG

# Overwrite LD Location Storage Account for AAT & Prod. Other environments will use the defaults provided in variables.tf file
rd_location_storage_repl_type   = "LRS"
rd_location_storage_access_tier = "Cool"