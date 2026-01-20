# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.naming_prefix}-${var.environment}-rg"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Log Analytics Workspace (required for Container Apps)
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.naming_prefix}-${var.environment}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.naming_prefix, "-", "")}${var.environment}${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# User Assigned Managed Identity for Container App
resource "azurerm_user_assigned_identity" "container_app" {
  name                = "${var.naming_prefix}-${var.environment}-id"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Role Assignment: Grant AcrPull to the managed identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_app.principal_id
}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.naming_prefix}-${var.environment}-cae"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Container App
resource "azurerm_container_app" "api" {
  name                         = "${var.naming_prefix}-${var.environment}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_app.id]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.container_app.id
  }

  template {
    container {
      name   = "products-api"
      image  = var.container_image
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 0
    max_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}

# API Management Service
resource "azurerm_api_management" "main" {
  name                = "${var.naming_prefix}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = "Consumption_0"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# API Management API
resource "azurerm_api_management_api" "products_api" {
  name                  = "products-api"
  resource_group_name   = azurerm_resource_group.main.name
  api_management_name   = azurerm_api_management.main.name
  revision              = "1"
  display_name          = "Products API"
  path                  = "api"
  protocols             = ["https"]
  service_url           = "https://${azurerm_container_app.api.ingress[0].fqdn}"
  subscription_required = false
}
