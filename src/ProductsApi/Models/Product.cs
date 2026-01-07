namespace ProductsApi.Models;

/// <summary>
/// Represents a product in the catalog
/// </summary>
public class Product
{
    /// <summary>
    /// Unique identifier for the product
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Product name
    /// </summary>
    public required string Name { get; set; }

    /// <summary>
    /// Product description
    /// </summary>
    public string? Description { get; set; }

    /// <summary>
    /// Product price in USD
    /// </summary>
    public decimal Price { get; set; }

    /// <summary>
    /// Current stock quantity
    /// </summary>
    public int StockQuantity { get; set; }

    /// <summary>
    /// Product category
    /// </summary>
    public string? Category { get; set; }

    /// <summary>
    /// Date when product was created
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
