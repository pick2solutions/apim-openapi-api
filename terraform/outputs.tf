output "apim_gateway_url" {
  description = "API Management Gateway URL"
  value       = azurerm_api_management.main.gateway_url
}

output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.api.ingress[0].fqdn
}

output "container_app_url" {
  description = "Container App URL"
  value       = "https://${azurerm_container_app.api.ingress[0].fqdn}"
}

output "apim_portal_url" {
  description = "API Management Developer Portal URL"
  value       = azurerm_api_management.main.developer_portal_url
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Azure Container Registry Login Server"
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Azure Container Registry Name"
  value       = azurerm_container_registry.main.name
}

output "container_app_name" {
  description = "Container App Name"
  value       = azurerm_container_app.api.name
}

output "managed_identity_client_id" {
  description = "User Assigned Managed Identity Client ID"
  value       = azurerm_user_assigned_identity.container_app.client_id
}

output "managed_identity_principal_id" {
  description = "User Assigned Managed Identity Principal ID"
  value       = azurerm_user_assigned_identity.container_app.principal_id
}
