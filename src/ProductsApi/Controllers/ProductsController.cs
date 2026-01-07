using Microsoft.AspNetCore.Mvc;
using ProductsApi.Models;

namespace ProductsApi.Controllers;

/// <summary>
/// Products controller for managing product catalog
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class ProductsController : ControllerBase
{
    // In-memory data store for demo purposes
    private static readonly List<Product> _products = new()
    {
        new Product
        {
            Id = 1,
            Name = "Laptop",
            Description = "High-performance laptop for developers",
            Price = 1299.99m,
            StockQuantity = 15,
            Category = "Electronics",
            CreatedAt = DateTime.UtcNow.AddDays(-30)
        },
        new Product
        {
            Id = 2,
            Name = "Wireless Mouse",
            Description = "Ergonomic wireless mouse with precision tracking",
            Price = 29.99m,
            StockQuantity = 50,
            Category = "Accessories",
            CreatedAt = DateTime.UtcNow.AddDays(-15)
        },
        new Product
        {
            Id = 3,
            Name = "Mechanical Keyboard",
            Description = "RGB mechanical keyboard with brown switches",
            Price = 149.99m,
            StockQuantity = 25,
            Category = "Accessories",
            CreatedAt = DateTime.UtcNow.AddDays(-7)
        }
    };

    /// <summary>
    /// Retrieves all products from the catalog
    /// </summary>
    /// <returns>A list of all products</returns>
    /// <response code="200">Returns the list of products</response>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<Product>), StatusCodes.Status200OK)]
    public ActionResult<IEnumerable<Product>> GetProducts()
    {
        return Ok(_products);
    }

    /// <summary>
    /// Retrieves a specific product by ID
    /// </summary>
    /// <param name="id">The unique identifier of the product</param>
    /// <returns>The requested product</returns>
    /// <response code="200">Returns the requested product</response>
    /// <response code="404">Product not found</response>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(Product), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public ActionResult<Product> GetProduct(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        
        if (product == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        return Ok(product);
    }

    /// <summary>
    /// Creates a new product in the catalog
    /// </summary>
    /// <param name="product">The product to create</param>
    /// <returns>The newly created product</returns>
    /// <response code="201">Product created successfully</response>
    /// <response code="400">Invalid product data</response>
    [HttpPost]
    [ProducesResponseType(typeof(Product), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public ActionResult<Product> CreateProduct([FromBody] Product product)
    {
        if (product == null)
        {
            return BadRequest(new { message = "Product data is required" });
        }

        // Generate new ID
        product.Id = _products.Any() ? _products.Max(p => p.Id) + 1 : 1;
        product.CreatedAt = DateTime.UtcNow;

        _products.Add(product);

        return CreatedAtAction(
            nameof(GetProduct),
            new { id = product.Id },
            product
        );
    }

    /// <summary>
    /// Updates an existing product
    /// </summary>
    /// <param name="id">The unique identifier of the product to update</param>
    /// <param name="product">The updated product data</param>
    /// <returns>No content</returns>
    /// <response code="204">Product updated successfully</response>
    /// <response code="400">Invalid product data or ID mismatch</response>
    /// <response code="404">Product not found</response>
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult UpdateProduct(int id, [FromBody] Product product)
    {
        if (product == null || id != product.Id)
        {
            return BadRequest(new { message = "Product ID mismatch or invalid data" });
        }

        var existingProduct = _products.FirstOrDefault(p => p.Id == id);
        
        if (existingProduct == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        // Update properties
        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.StockQuantity = product.StockQuantity;
        existingProduct.Category = product.Category;

        return NoContent();
    }

    /// <summary>
    /// Deletes a product from the catalog
    /// </summary>
    /// <param name="id">The unique identifier of the product to delete</param>
    /// <returns>No content</returns>
    /// <response code="204">Product deleted successfully</response>
    /// <response code="404">Product not found</response>
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult DeleteProduct(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        
        if (product == null)
        {
            return NotFound(new { message = $"Product with ID {id} not found" });
        }

        _products.Remove(product);

        return NoContent();
    }
}
