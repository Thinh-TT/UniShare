namespace UniShare.API.Models.DTOs.Metadata;

public class TagDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;
}
