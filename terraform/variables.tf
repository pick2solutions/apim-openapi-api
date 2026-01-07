variable "naming_prefix" {
  description = "Naming prefix for all resources"
  type        = string
  default     = "apim-openapi"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "mcr.microsoft.com/dotnet/samples:aspnetapp"
}

variable "apim_publisher_name" {
  description = "API Management publisher name"
  type        = string
  default     = "My Organization"
}

variable "apim_publisher_email" {
  description = "API Management publisher email"
  type        = string
  default     = "admin@example.com"
}
