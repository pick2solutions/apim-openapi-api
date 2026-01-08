# Products API - Azure Container Apps Deployment

A production-ready .NET 10 API for managing product catalog data, deployed to Azure Container Apps with automated CI/CD and Azure API Management integration.

## Why This Matters: OpenAPI and the Future of AI Integration

**Well-documented APIs are foundational for modern development practices.** Comprehensive OpenAPI specifications with detailed descriptions, parameter definitions, and response schemas are not just "nice to have"—they're essential for:

- **Developer Experience**: Clear documentation reduces integration time and support overhead
- **API Management**: APIM relies on OpenAPI specs to understand and proxy your endpoints
- **MCP Server Integration**: Azure API Management's upcoming Model Context Protocol (MCP) server capabilities require well-structured OpenAPI definitions. MCP servers expose APIs as tools that AI agents can discover and invoke—making proper documentation a **silent prerequisite** for AI-assisted workflows.

This project demonstrates best practices for creating production-ready APIs with complete OpenAPI documentation using Swashbuckle and XML comments.

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
- [Cost Considerations](#cost-considerations)
- [Troubleshooting](#troubleshooting)

## Overview

This project implements a complete end-to-end deployment pipeline for a .NET API that:

- **Builds and tests** the API automatically on code changes
- **Generates OpenAPI specifications** from the compiled code with XML documentation
- **Containerizes** the application using Docker
- **Deploys** to Azure Container Apps for serverless container hosting
- **Exposes** the API through Azure API Management (APIM) as a managed gateway

The system is designed for reliability, maintainability, and automated deployment workflows with comprehensive API documentation that supports both human developers and AI agent integration.

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
│    (with XML)   │
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
│  - Scales to 0  │
│  - Min: 0       │
│  - Max: 1       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Azure API      │
│  Management     │
│ (Consumption)   │
│  - Gateway      │
│  - MCP Ready    │
└─────────────────┘
```

### Component Responsibilities

| Component | Purpose |
|-----------|---------|
| **GitHub Actions** | Automated build, test, and deployment pipeline |
| **Azure Container Registry** | Secure storage for Docker images |
| **Azure Container Apps** | Serverless container hosting (scales to zero for cost efficiency) |
| **Azure API Management** | API gateway, security, documentation, and future MCP server support |
| **Log Analytics Workspace** | Centralized logging and monitoring |

## Features

### API Capabilities
- Full CRUD operations for product management
- Automatic OpenAPI/Swagger documentation with XML comments
- RESTful endpoint design with proper HTTP status codes
- Structured product model with validation
- Response annotations for clear API contracts

### DevOps Features
- Automated CI/CD with GitHub Actions
- Infrastructure as Code with Terraform
- OpenID Connect (OIDC) authentication for Azure
- Immutable container image tagging (timestamp + commit SHA)
- Zero-downtime deployments
- Automatic API contract synchronization

### Cost Optimization
- Container Apps scales to zero (no cost when idle)
- APIM Consumption tier (pay per use: $0.035 per 10K calls)
- Log Analytics pay-as-you-go pricing
- Minimal replica configuration (0 min, 1 max)

## Prerequisites

### Development Tools
- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Visual Studio Code](https://code.visualstudio.com/) or [Visual Studio 2022](https://visualstudio.microsoft.com/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads) (v1.0 or later)

### Azure Resources
- Azure Subscription
- Azure Container Registry
- Azure Container Apps Environment
- Azure API Management instance (Consumption tier)
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

**Important**: The Swagger UI provides interactive API documentation generated from XML comments in the code. This same documentation powers the OpenAPI specification used by APIM.

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

Access the containerized API at `http://localhost:8080/swagger`

## Infrastructure Setup

### Using Terraform (Recommended)

The infrastructure is provisioned using Terraform located in the `terraform/` directory.

#### Resources Created

1. **Resource Group** - Container for all resources
2. **Log Analytics Workspace** - Logging and monitoring
3. **Container App Environment** - Hosting environment for containers
4. **Container App** - Runs the API container
   - Min replicas: 0 (scales to zero)
   - Max replicas: 1
   - Port: 8080
   - External ingress enabled
5. **API Management** - Consumption tier
   - Gateway for API exposure
   - Operations for Products API endpoints
   - Ready for MCP server integration

#### Initialize Terraform

```bash
cd terraform
terraform init
```

#### Customize Deployment (Optional)

Create a `terraform.tfvars` file:

```hcl
naming_prefix         = "my-api"
environment          = "prod"
location             = "eastus"
apim_publisher_name  = "My Company"
apim_publisher_email = "admin@mycompany.com"
```

#### Plan Infrastructure Changes

```bash
terraform plan
```

#### Apply Infrastructure

```bash
terraform apply
```

#### Output Values

After deployment, Terraform provides:
- `apim_gateway_url` - API Management gateway URL
- `container_app_fqdn` - Container App FQDN
- `container_app_url` - Full Container App URL

#### Deploy Custom Container Image

```bash
terraform apply -var="container_image=myregistry.azurecr.io/products-api:latest"
```

### Manual Azure Setup

If not using Terraform, create the following resources:

1. **Resource Group**
   ```bash
   az group create --name products-api-rg --location eastus
   ```

2. **Log Analytics Workspace**
   ```bash
   az monitor log-analytics workspace create \
     --resource-group products-api-rg \
     --workspace-name products-logs
   ```

3. **Container Registry**
   ```bash
   az acr create --name myacr --resource-group products-api-rg --sku Basic
   ```

4. **Container Apps Environment**
   ```bash
   WORKSPACE_ID=$(az monitor log-analytics workspace show \
     --resource-group products-api-rg \
     --workspace-name products-logs \
     --query customerId -o tsv)
   
   WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
     --resource-group products-api-rg \
     --workspace-name products-logs \
     --query primarySharedKey -o tsv)
   
   az containerapp env create \
     --name products-env \
     --resource-group products-api-rg \
     --location eastus \
     --logs-workspace-id $WORKSPACE_ID \
     --logs-workspace-key $WORKSPACE_KEY
   ```

5. **Container App**
   ```bash
   az containerapp create \
     --name products-api \
     --resource-group products-api-rg \
     --environment products-env \
     --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
     --target-port 8080 \
     --ingress external \
     --min-replicas 0 \
     --max-replicas 1
   ```

6. **API Management (Consumption Tier)**
   ```bash
   az apim create \
     --name products-apim \
     --resource-group products-api-rg \
     --publisher-name "Your Company" \
     --publisher-email admin@example.com \
     --sku-name Consumption
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
   - Setup .NET 10 SDK for application build
   - Setup .NET 7 runtime for Swashbuckle CLI compatibility
   - Restore dependencies
   - Build application in Release mode
   - **Generate OpenAPI specification** from compiled DLL with XML documentation
   - Upload OpenAPI artifact for later use
   - Run unit tests (continues on error)

2. **Build and Push Docker Image** (main branch only)
   - Generate unique image tag: `YYYYMMDDHHMMSS-<7-char-sha>`
   - Authenticate to Azure using OIDC (passwordless)
   - Retrieve ACR credentials dynamically
   - Build Docker image with two tags:
     - Specific version: `<timestamp>-<sha>`
     - Latest: `latest`
   - Push both tags to Azure Container Registry

3. **Deploy to Container App**
   - Authenticate to Azure
   - Retrieve infrastructure details (ACR, Container App)
   - Update Container App with new image
   - Display deployment URL and Swagger endpoint

4. **Update APIM**
   - Download OpenAPI artifact from build job
   - Import OpenAPI specification directly into APIM
   - No revisions used (direct import for reliability)
   - Preserves existing API policies
   - Updates operations and schemas automatically

#### 2. Terraform Infrastructure (`terraform.yml`)

Triggered on:
- Push to `main` branch (with changes to `terraform/**` or workflow file)
- Manual workflow dispatch

**Jobs:**

1. **Terraform Plan & Apply**
   - Checkout code
   - Setup Terraform (v1.5.0)
   - Authenticate to Azure using OIDC
   - Format check (`terraform fmt`)
   - Initialize with remote backend
   - Validate configuration
   - Plan infrastructure changes
   - Apply changes (on main branch push only)
   - Output infrastructure details

### Pipeline Features

- **OIDC Authentication**: Passwordless authentication using OpenID Connect
- **Immutable Images**: Each deployment creates a uniquely tagged image
- **Artifact Management**: OpenAPI specs stored as pipeline artifacts
- **Fail-Safe Testing**: Tests run but don't block deployment (configurable)
- **Automatic API Sync**: APIM automatically updated with latest API contract
- **XML Documentation Flow**: XML comments → OpenAPI spec → APIM documentation

### Key Design Decisions

- **Single source of truth for OpenAPI** (generated from build, not manually edited)
- **No manual OpenAPI edits** (all changes made in code XML comments)
- **No APIM revisions in CI/CD** (direct import for reliability and simplicity)
- **Direct APIM imports** (avoids revision validation issues)
- **Immutable container images** (timestamp + SHA tagging)
- **Stable public API surface** (consistent API ID and path)

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
2. Generate OpenAPI documentation from XML comments
3. Create and push a Docker image
4. Deploy to Azure Container Apps
5. Update Azure API Management with new API contract

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

3. **Access Swagger UI**
   ```
   https://<container-app-fqdn>/swagger
   ```

4. **Verify APIM**
   - Navigate to Azure Portal → API Management
   - Select your APIM instance
   - Go to APIs → products-api
   - Verify operations are up-to-date with descriptions from XML comments
   - Check that schemas include documentation
   - Use the "Test" tab to execute requests through APIM gateway

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

**Field Documentation** (from XML comments):
- `id` - Unique identifier for the product
- `name` - Product name (required)
- `description` - Product description (optional)
- `price` - Product price in USD
- `stockQuantity` - Current stock quantity
- `category` - Product category (optional)
- `createdAt` - Date when product was created

### Swagger UI

Access interactive API documentation:
- **Container App**: `https://<container-app-fqdn>/swagger`
- **APIM Developer Portal**: `https://<apim-name>.developer.azure-api.net`

The Swagger UI provides:
- Complete API documentation from XML comments
- Interactive testing of endpoints
- Request/response examples
- Schema definitions with field descriptions

### OpenAPI Specification

Download the OpenAPI specification:
- **From GitHub Actions artifacts** (each build generates the spec)
- **From APIM**: `https://<apim-name>.management.azure-api.net/apis/products-api?format=openapi.json`
- **From Container App**: `https://<container-app-fqdn>/swagger/v1/swagger.json`

The OpenAPI spec includes:
- All endpoint definitions with descriptions
- Request/response schemas
- Parameter documentation
- XML comment annotations
- Response status codes

### Writing Good API Documentation

For AI agent integration and MCP server support, follow these best practices:

1. **Add XML comments to all public models**:
   ```csharp
   /// <summary>
   /// Represents a product in the catalog
   /// </summary>
   public class Product
   {
       /// <summary>
       /// Unique identifier for the product
       /// </summary>
       public int Id { get; set; }
   }
   ```

2. **Document controller actions**:
   ```csharp
   /// <summary>
   /// Retrieves all products from the catalog
   /// </summary>
   /// <returns>A list of all products</returns>
   [HttpGet]
   [ProducesResponseType(StatusCodes.Status200OK)]
   public ActionResult<IEnumerable<Product>> GetProducts()
   ```

3. **Annotate response types**:
   ```csharp
   [ProducesResponseType(StatusCodes.Status200OK)]
   [ProducesResponseType(StatusCodes.Status404NotFound)]
   ```

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

### Container App Scaling

Configured via Terraform or Azure CLI:
- **Min replicas**: 0 (scales to zero for cost savings)
- **Max replicas**: 1 (single instance for simple workloads)
- **Scale rules**: HTTP concurrency-based (default)

To modify:
```bash
az containerapp update \
  --name products-api \
  --resource-group products-api-rg \
  --min-replicas 1 \
  --max-replicas 5
```

### APIM Policies

Add custom policies in Azure Portal:
1. Navigate to APIM → APIs → products-api
2. Select "All operations" or specific operation
3. Click "Add policy" in Inbound/Outbound processing
4. Configure:
   - Rate limiting
   - CORS
   - Authentication (OAuth, API keys)
   - Request transformation
   - Caching

Example rate limit policy:
```xml
<inbound>
    <rate-limit calls="100" renewal-period="60" />
</inbound>
```

## Cost Considerations

This architecture is optimized for cost efficiency:

### Azure Container Apps
- **Consumption-based pricing**: Pay only for resources used
- **Scales to zero**: No cost when API is idle
- **Minimal replicas**: 0 min, 1 max configuration
- **Estimated cost**: ~$0 when idle, ~$15-30/month under moderate load

### API Management (Consumption Tier)
- **Pay-per-call**: $0.035 per 10,000 calls
- **No fixed costs**: No minimum monthly charge
- **Free tier**: First 1 million calls free per Azure subscription
- **Estimated cost**: ~$3.50 per 1 million calls after free tier

### Log Analytics
- **Pay-as-you-go**: Based on data ingestion
- **First 5GB free** per month
- **Estimated cost**: ~$2-5/month for typical API logging

### Total Estimated Monthly Cost
- **Light usage** (idle most of time): <$5/month
- **Moderate usage** (100K calls/month): ~$10-20/month
- **Heavy usage** (1M calls/month): ~$50-75/month

### Cost Optimization Tips
1. Let Container Apps scale to zero during off-hours
2. Configure appropriate log retention policies
3. Use APIM caching to reduce backend calls
4. Monitor usage with Azure Cost Management

## Troubleshooting

### Common Issues

#### Build Failures

**Problem**: OpenAPI generation fails
```
Error: swagger: command not found
```
**Solution**: Ensure .NET 7 runtime is installed for Swashbuckle CLI
```bash
dotnet tool install --global Swashbuckle.AspNetCore.Cli --version 6.5.0
```

**Problem**: Docker build fails
```
ERROR: failed to solve: failed to compute cache key
```
**Solution**: Check Dockerfile path and build context in workflow. Ensure working directory is set correctly.

**Problem**: XML documentation not appearing in OpenAPI
```xml
<!-- Add to ProductsApi.csproj -->
<PropertyGroup>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <NoWarn>$(NoWarn);1591</NoWarn>
</PropertyGroup>
```

#### Deployment Issues

**Problem**: Container App update fails
```bash
# Check Container App logs
az containerapp logs show --name products-api --resource-group products-api-rg --follow
```

**Problem**: APIM import fails
```
Error: OpenAPI validation failed
```
**Solution**: 
- Verify OpenAPI spec is valid using [Swagger Editor](https://editor.swagger.io/)
- Check APIM API ID and path are correct
- Ensure APIM has sufficient permissions

**Problem**: Container App stuck in "Provisioning" state
```bash
# Check provisioning status
az containerapp show --name products-api --resource-group products-api-rg --query "properties.provisioningState"

# Check revision status
az containerapp revision list --name products-api --resource-group products-api-rg
```

#### Runtime Issues

**Problem**: API returns 503 Service Unavailable
```bash
# Check if Container App is scaled to zero
az containerapp revision list --name products-api --resource-group products-api-rg

# Check Container App health
az containerapp show --name products-api --resource-group products-api-rg --query "properties.runningStatus"
```
**Solution**: First request after idle period may take 10-15 seconds as Container App scales from zero.

**Problem**: APIM returns 404 for valid endpoint
```
Error: Resource not found
```
**Solution**: 
- Verify backend URL in APIM settings points to Container App FQDN
- Confirm API path configuration matches expected route
- Check APIM operations were imported correctly

**Problem**: Swagger UI not loading
```
Error: Failed to load API definition
```
**Solution**:
- Ensure `AddSwaggerGen()` is called in `Program.cs`
- Verify XML documentation file is being generated
- Check that Swagger middleware is configured correctly

#### Performance Issues

**Problem**: Slow cold start times
```
Solution: Consider setting min replicas to 1 if consistent performance is critical
```

**Problem**: High Log Analytics costs
```bash
# Check data ingestion
az monitor log-analytics workspace show \
  --resource-group products-api-rg \
  --workspace-name products-logs \
  --query "retentionInDays"

# Reduce retention period
az monitor log-analytics workspace update \
  --resource-group products-api-rg \
  --workspace-name products-logs \
  --retention-time 30
```

### Debug Commands

```bash
# View Container App revisions
az containerapp revision list --name products-api --resource-group products-api-rg

# Stream Container App logs
az containerapp logs show --name products-api --resource-group products-api-rg --follow --tail 100

# Test APIM API
az apim api show --resource-group products-api-rg --service-name products-apim --api-id products-api

# List APIM operations
az apim api operation list --resource-group products-api-rg --service-name products-apim --api-id products-api

# List ACR images
az acr repository show-tags --name myacr --repository products-api --orderby time_desc

# Check workflow run status
gh run list --workflow=dotnet-cicd.yml

# View Terraform state
cd terraform
terraform show

# Check Container App environment
az containerapp env show --name products-env --resource-group products-api-rg
```

### Getting Help

- Review GitHub Actions logs for detailed error messages
- Check Azure Portal for service health and metrics
- Monitor Container Apps metrics in Azure Monitor
- Review APIM analytics for API usage patterns
- Consult documentation:
  - [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/)
  - [Azure API Management](https://learn.microsoft.com/azure/api-management/)
  - [Swashbuckle Documentation](https://github.com/domaindrivendev/Swashbuckle.AspNetCore)

## Next Steps

### Immediate Actions
1. ✅ Push your Docker image to Azure Container Registry
2. ✅ Update Terraform variable `container_image` to your image
3. ✅ Run initial Terraform deployment

### Production Readiness
1. Configure API Management policies:
   - Rate limiting to prevent abuse
   - Authentication (OAuth 2.0, API keys, or JWT)
   - CORS for web applications
   - Request/response transformation
2. Set up custom domain names for APIM and Container App
3. Enable Application Insights for detailed monitoring
4. Configure alerts for:
   - High error rates
   - Slow response times
   - Scaling events
   - Cost thresholds
5. Implement proper error handling and logging
6. Add integration tests to CI/CD pipeline
7. Set up staging environment

### Advanced Features
1. Enable APIM revision management for testing new versions
2. Configure APIM products and subscriptions for different customer tiers
3. Implement API versioning (v1, v2, etc.)
4. Add authentication to Container App (Entra ID, etc.)
5. Set up VNet integration for private networking
6. Configure backup and disaster recovery
7. Implement observability with distributed tracing
8. Prepare for MCP server integration (monitor Azure updates)


## Acknowledgments

- Azure Container Apps team for excellent documentation
- Swashbuckle for OpenAPI generation
- GitHub Actions for reliable CI/CD
- Anthropic for MCP protocol development