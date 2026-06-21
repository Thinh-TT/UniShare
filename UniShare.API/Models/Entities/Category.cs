using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Category : BaseEntity
{
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<Listing> Listings { get; set; } = new List<Listing>();
}
