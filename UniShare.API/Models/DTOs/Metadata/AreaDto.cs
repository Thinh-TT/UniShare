namespace UniShare.API.Models.DTOs.Metadata;

public class AreaDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string City { get; set; } = null!;
    public string? Description { get; set; }
}
