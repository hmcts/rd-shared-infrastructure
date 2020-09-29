aks_infra_subscription_id  = "96c274ce-846d-4e48-89a7-d528432298a7"
mgmt_subscription_id       = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
managed_identity_object_id = "73cd460f-d69c-4761-be6f-3d6b5614ede8"

# Overwrite LD Location Storage Account for AAT & Prod. Other environments will use the defaults provided in variables.tf file
ld_location_storage_repl_type   = "ZRS"
ld_location_storage_access_tier = "Hot"