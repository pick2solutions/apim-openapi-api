# Products API - Azure Container Apps Deployment

A production-ready .NET 10 API for managing product catalog data, deployed to Azure Container Apps with automated CI/CD and Azure API Management integration.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Infrastructure Setup](#infrastructure-setup)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## Overview

This project implements a complete end-to-end deployment pipeline for a .NET API that:

- **Builds and tests** the API automatically on code changes
- **Generates OpenAPI specifications** from the compiled code
- **Containerizes** the application using Docker
- **Deploys** to Azure Container Apps for serverless container hosting
- **Exposes** the API through Azure API Management (APIM) as a managed gateway

The system is designed for reliability, maintainability, and automated deployment workflows.

## Architecture

```
┌─────────────┐
│   GitHub    │
│  Repository │
└──────┬──────┘
       │
       │ Push to main
       ▼
┌─────────────────┐
│ GitHub Actions  │
│   CI/CD         │
├─────────────────┤
│ 1. Build & Test │
│ 2. Generate     │
│    OpenAPI      │
│ 3. Build Docker │
│    Image        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Azure Container│
│    Registry     │
│      (ACR)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Azure Container│
│      Apps       │
│  (API Runtime)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Azure API      │
│  Management     │
│  (Public API)   │
└─────────────────┘
```

### Component Responsibilities

| Component | Purpose |
|-----------|---------|
| **GitHub Actions** | Automated build, test, and deployment pipeline |
| **Azure Container Registry** | Secure storage for Docker images |
| **Azure Container Apps** | Serverless container hosting platform |
| **Azure API Management** | API gateway, security, and documentation |

## Features

### API Capabilities
- Full CRUD operations for product management
- Automatic OpenAPI/Swagger documentation
- RESTful endpoint design
- Structured product model with validation

### DevOps Features
- Automated CI/CD with GitHub Actions
- Infrastructure as Code with Terraform
- OpenID Connect (OIDC) authentication for Azure
- Immutable container image tagging
- Zero-downtime deployments
- Automatic API contract synchronization

## Prerequisites

### Development Tools
- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/) or [Visual Studio 2022](https://visualstudio.microsoft.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads) (v1.5.0 or later)

### Azure Resources
- Azure Subscription
- Azure Container Registry
- Azure Container Apps Environment
- Azure API Management instance
- Azure Service Principal with appropriate permissions

### GitHub Secrets Required

Configure the following secrets in your GitHub repository (`Settings > Secrets and variables > Actions`):

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CLIENT_ID` | Service Principal Application (client) ID |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `AZURE_RESOURCE_GROUP` | Resource group containing infrastructure |
| `APIM_NAME` | Azure API Management instance name |

## Local Development

### Clone the Repository

```bash
git clone https://github.com/your-org/apim-openapi-api.git
cd apim-openapi-api
```

### Run Locally

```bash
cd src/ProductsApi
dotnet restore
dotnet build
dotnet run
```

The API will be available at:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `https://localhost:5001/swagger`

### Run Tests

```bash
cd src/ProductsApi
dotnet test
```

### Build Docker Image Locally

```bash
cd src/ProductsApi
docker build -t products-api:local .
docker run -p 8080:8080 products-api:local
```

## Infrastructure Setup

### Using Terraform

The infrastructure is provisioned using Terraform located in the `terraform/` directory.

#### Initialize Terraform

```bash
cd terraform
terraform init -backend-config=backend.conf
```

#### Plan Infrastructure Changes

```bash
terraform plan -out=tfplan
```

#### Apply Infrastructure

```bash
terraform apply tfplan
```

### Manual Azure Setup

If not using Terraform, create the following resources:

1. **Resource Group**
   ```bash
   az group create --name products-api-rg --location eastus
   ```

2. **Container Registry**
   ```bash
   az acr create --name myacr --resource-group products-api-rg --sku Basic
   ```

3. **Container Apps Environment**
   ```bash
   az containerapp env create --name products-env --resource-group products-api-rg --location eastus
   ```

4. **Container App**
   ```bash
   az containerapp create \
     --name products-api \
     --resource-group products-api-rg \
     --environment products-env \
     --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
     --target-port 8080 \
     --ingress external
   ```

5. **API Management**
   ```bash
   az apim create --name products-apim --resource-group products-api-rg --publisher-name "Your Company" --publisher-email admin@example.com --sku-name Developer
   ```

## CI/CD Pipeline

### Workflow Overview

The deployment pipeline consists of two main workflows:

#### 1. .NET CI/CD (`dotnet-cicd.yml`)

Triggered on:
- Push to `main` branch (with changes to `src/**` or workflow file)
- Pull requests to `main`
- Manual workflow dispatch

**Jobs:**

1. **Build and Test**
   - Checkout code
   - Setup .NET 10 and .NET 7 runtimes
   - Restore dependencies
   - Build application
   - Generate OpenAPI specification
   - Run tests
   - Upload OpenAPI artifact

2. **Build and Push Docker Image** (main branch only)
   - Generate unique image tag (timestamp + commit SHA)
   - Authenticate to Azure using OIDC
   - Retrieve ACR credentials
   - Build and push Docker image with two tags: `<timestamp>-<sha>` and `latest`

3. **Deploy to Container App**
   - Authenticate to Azure
   - Update Container App with new image
   - Display deployment URL and Swagger endpoint

4. **Update APIM**
   - Download OpenAPI artifact
   - Import OpenAPI specification into APIM
   - Preserve existing API policies

#### 2. Terraform Infrastructure (`terraform.yml`)

Triggered on:
- Push to `main` branch (with changes to `terraform/**` or workflow file)
- Manual workflow dispatch

**Jobs:**

1. **Terraform Plan & Apply**
   - Format check
   - Initialize Terraform with remote backend
   - Validate configuration
   - Plan infrastructure changes
   - Apply changes (on main branch push)
   - Output infrastructure details

### Pipeline Features

- **OIDC Authentication**: Passwordless authentication using OpenID Connect
- **Immutable Images**: Each deployment creates a uniquely tagged image
- **Artifact Management**: OpenAPI specs are stored as pipeline artifacts
- **Fail-Safe Testing**: Tests run but don't block deployment (configurable)
- **Automatic API Sync**: APIM is automatically updated with latest API contract

## Deployment

### Automatic Deployment

Simply push code to the `main` branch:

```bash
git add .
git commit -m "Add new product endpoint"
git push origin main
```

The pipeline will automatically:
1. Build and test the application
2. Generate OpenAPI documentation
3. Create and push a Docker image
4. Deploy to Azure Container Apps
5. Update Azure API Management

### Manual Deployment

Trigger a deployment manually from GitHub Actions:
1. Go to `Actions` tab in GitHub
2. Select `.NET CI/CD` workflow
3. Click `Run workflow`
4. Select `main` branch
5. Click `Run workflow`

### Verify Deployment

After deployment completes:

1. **Check Container App**
   ```bash
   az containerapp show --name products-api --resource-group products-api-rg --query "properties.configuration.ingress.fqdn"
   ```

2. **Test API Directly**
   ```bash
   curl https://<container-app-fqdn>/api/products
   ```

3. **Verify APIM**
   - Navigate to Azure Portal → API Management
   - Select your APIM instance
   - Go to APIs → products-api
   - Verify operations are up-to-date
   - Use the "Test" tab to execute requests

## API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | List all products |
| GET | `/api/products/{id}` | Get product by ID |
| POST | `/api/products` | Create new product |
| PUT | `/api/products/{id}` | Update existing product |
| DELETE | `/api/products/{id}` | Delete product |

### Product Model

```json
{
  "id": 1,
  "name": "Product Name",
  "description": "Product description",
  "price": 29.99,
  "stockQuantity": 100,
  "category": "Electronics",
  "createdAt": "2025-01-08T10:30:00Z"
}
```

### Swagger UI

Access interactive API documentation:
- **Container App**: `https://<container-app-fqdn>/swagger`
- **APIM Developer Portal**: `https://<apim-name>.developer.azure-api.net`

### OpenAPI Specification

Download the OpenAPI specification:
- From GitHub Actions artifacts (each build)
- From APIM: `https://<apim-name>.management.azure-api.net/apis/products-api?format=openapi.json`

## Configuration

### Environment Variables

Configure in Azure Container App settings:

| Variable | Description | Default |
|----------|-------------|---------|
| `ASPNETCORE_ENVIRONMENT` | Runtime environment | `Production` |
| `ASPNETCORE_URLS` | Listening URLs | `http://+:8080` |

### Application Settings

Modify `appsettings.json` or `appsettings.Production.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### APIM Policies

Add custom policies in Azure Portal:
1. Navigate to APIM → APIs → products-api
2. Select "All operations" or specific operation
3. Click "Add policy" in Inbound/Outbound processing
4. Configure rate limiting, CORS, authentication, etc.

## Troubleshooting

### Common Issues

#### Build Failures

**Problem**: OpenAPI generation fails
```
Solution: Ensure .NET 7 runtime is installed for Swashbuckle CLI
```

**Problem**: Docker build fails
```
Solution: Check Dockerfile path and build context in workflow
```

#### Deployment Issues

**Problem**: Container App update fails
```bash
# Check Container App logs
az containerapp logs show --name products-api --resource-group products-api-rg --follow
```

**Problem**: APIM import fails
```
Solution: Verify OpenAPI spec is valid using Swagger Editor
Solution: Check APIM API ID and path are correct
```

#### Runtime Issues

**Problem**: API returns 503 Service Unavailable
```bash
# Check revision traffic allocation
az containerapp revision list --name products-api --resource-group products-api-rg
```

**Problem**: APIM returns 404 for valid endpoint
```
Solution: Verify backend URL in APIM settings
Solution: Confirm API path configuration matches expected route
```

### Debug Commands

```bash
# View Container App revisions
az containerapp revision list --name products-api --resource-group products-api-rg

# Stream Container App logs
az containerapp logs show --name products-api --resource-group products-api-rg --follow --tail 100

# Test APIM API
az apim api show --resource-group products-api-rg --service-name products-apim --api-id products-api

# List ACR images
az acr repository show-tags --name myacr --repository products-api --orderby time_desc

# Check workflow run status
gh run list --workflow=dotnet-cicd.yml
```

### Getting Help

- Review GitHub Actions logs for detailed error messages
- Check Azure Portal for service health and metrics
- Consult Azure Container Apps documentation: https://learn.microsoft.com/azure/container-apps/
- Review APIM documentation: https://learn.microsoft.com/azure/api-management/
## Acknowledgments

- Azure Container Apps team for excellent documentation
- Swashbuckle for OpenAPI generation
- GitHub Actions for reliable CI/CD