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

variable "common_tags" {
  type = "map"
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
  default     = "Web"
  description = "Type of Application Insights (Web/Other)"
}

variable "team_name" {
  default     = "Reference Data"
}

variable "team_contact" {
  default     = "#referencedata"
}

