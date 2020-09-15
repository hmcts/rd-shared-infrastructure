variable "product" {
  type        = "string"
  default     = "rd"
  description = "The name of your application"
}

variable "env" {
  type        = "string"
  description = "The deployment environment (sandbox, aat, prod etc..)"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

variable "tenant_id" {
  type        = "string"
  description = "The Tenant ID of the Azure Active Directory"
}

variable "jenkins_AAD_objectId" {
  type        = "string"
  description = "This is the ID of the Application you wish to give access to the Key Vault via the access policy"
}

variable "rd_product_group_object_id" {
  type    = "string"
  default = "35327411-b189-467e-a8db-9fb833745484"
}

// as of now, UK South is unavailable for Application Insights
variable "appinsights_location" {
  type        = "string"
  default     = "West Europe"
  description = "Location for Application Insights"
}

variable "appinsights_application_type" {
  type        = "string"
  default     = "web"
  description = "Type of Application Insights (Web/Other)"
}

variable "team_name" {
  type        = "string"
  description = "Team name"
  default     = "ReferenceData"
}

variable "team_contact" {
  type        = "string"
  description = "Team contact"
  default     = "#referencedata"
}

variable "destroy_me" {
  type        = "string"
  description = "Here be dragons! In the future if this is set to Yes then automation will delete this resource on a schedule. Please set to No unless you know what you are doing"
  default     = "No"
}

variable "managed_identity_object_id" {
  default = ""
}

variable "subscription" {}

variable "mgmt_subscription_id" {}

# variable "mgmt_subscription_id" {
#   type    = "string"
#   default = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348" # DTS-CFTPTL-INTSVC
# }

variable "jenkins_subscription_id" {
  type    = "string"
  default = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348" # DTS-CFTPTL-INTSVC
}

variable "aks_infra_subscription_id" {}

variable "common_tags" {
  type = "map"
}