namespace UniShare.API.Models.DTOs.Metadata;

public class CreateCategoryRequest
{
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string? Description { get; set; }
}
