namespace UniShare.API.Models.DTOs.Metadata;

public class SchoolDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string ShortName { get; set; } = null!;
    public string City { get; set; } = null!;
}
