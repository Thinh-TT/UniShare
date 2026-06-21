using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Tag : BaseEntity
{
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;

    // Navigation properties
    public ICollection<ListingTag> ListingTags { get; set; } = new List<ListingTag>();
}
