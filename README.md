# APIM OpenAPI API Project

This project contains a .NET 10 Web API with OpenAPI/Swagger documentation and Terraform configuration for deploying to Azure Container Apps with API Management.

## Why OpenAPI Documentation Matters

**Well-documented APIs are foundational for modern development practices.** Comprehensive OpenAPI specifications with detailed descriptions, parameter definitions, and response schemas are not just "nice to have"—they're essential for:

- **Developer Experience**: Clear documentation reduces integration time and support overhead
- **API Management**: APIM relies on OpenAPI specs to understand and proxy your endpoints
- **MCP Server Integration**: Azure API Management's upcoming Model Context Protocol (MCP) server capabilities require well-structured OpenAPI definitions. MCP servers expose APIs as tools that AI agents can discover and invoke—making proper documentation a **silent prerequisite** for AI-assisted workflows.

This project demonstrates best practices for creating production-ready APIs with complete OpenAPI documentation using Swashbuckle and XML comments.

## Project Structure

```
├── src/
│   └── ProductsApi/          # .NET 10 Web API project
│       ├── Controllers/       # API controllers
│       ├── Models/           # Data models
│       ├── Program.cs        # Application entry point
│       ├── ProductsApi.csproj
│       └── Dockerfile        # Container image definition
└── terraform/                # Azure infrastructure as code
    ├── providers.tf          # Terraform provider configuration
    ├── variables.tf          # Input variables
    ├── main.tf              # Main infrastructure resources
    └── outputs.tf           # Output values
```

## .NET API

### Features

- **OpenAPI/Swagger**: Full API documentation with Swagger UI
- **XML Documentation**: XML comments flow through to OpenAPI spec
- **RESTful Endpoints**: CRUD operations for Products
- **Response Annotations**: Proper HTTP status codes and response types
- **Docker Support**: Containerized for deployment to Azure Container Apps

### Endpoints

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get a product by ID
- `POST /api/products` - Create a new product
- `PUT /api/products/{id}` - Update an existing product
- `DELETE /api/products/{id}` - Delete a product

### Local Development

1. Navigate to the API directory:
   ```bash
   cd src/ProductsApi
   ```

2. Restore dependencies:
   ```bash
   dotnet restore
   ```

3. Run the application:
   ```bash
   dotnet run
   ```

4. Access Swagger UI at `http://localhost:5000` (or the URL shown in the console)

### Build Docker Image

```bash
cd src/ProductsApi
docker build -t products-api:latest .
docker run -p 8080:8080 products-api:latest
```

## Terraform Deployment

### Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Terraform installed (>= 1.0)
- Azure subscription

### Deploy Infrastructure

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Note the output values:
   - `apim_gateway_url` - API Management gateway URL
   - `container_app_fqdn` - Container App FQDN
   - `container_app_url` - Full Container App URL

### Custom Variables

Create a `terraform.tfvars` file to customize deployment:

```hcl
naming_prefix         = "my-api"
environment          = "prod"
location             = "eastus"
apim_publisher_name  = "My Company"
apim_publisher_email = "admin@mycompany.com"
```

### Deploy Custom Container Image

After building your Docker image and pushing to a container registry:

```bash
terraform apply -var="container_image=myregistry.azurecr.io/products-api:latest"
```

## Azure Resources

The Terraform configuration creates:

1. **Resource Group** - Container for all resources
2. **Log Analytics Workspace** - Logging and monitoring
3. **Container App Environment** - Hosting environment for containers
4. **Container App** - Runs the API container
   - Min replicas: 0 (scales to zero)
   - Max replicas: 1
   - Port: 8080
   - External ingress enabled
5. **API Management** - Consumption tier (cheapest)
   - Gateway for API exposure
   - Operations for Products API endpoints

## Cost Considerations

- **Container Apps**: Consumption-based pricing (scales to zero)
- **API Management**: Consumption tier ($0.035 per 10K calls)
- **Log Analytics**: Pay-as-you-go based on ingestion

## Next Steps

1. Push your Docker image to Azure Container Registry
2. Update Terraform variable `container_image` to your image
3. Configure API Management policies (rate limiting, authentication, etc.)
4. Set up CI/CD pipeline for automated deployments
5. Configure custom domain names
6. Enable Application Insights for monitoring
