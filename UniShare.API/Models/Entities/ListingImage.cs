using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class ListingImage : BaseEntity
{
    public Guid ListingId { get; set; }
    public string ImageUrl { get; set; } = null!;
    public int DisplayOrder { get; set; }
    public bool IsCover { get; set; }

    // Navigation properties
    public Listing Listing { get; set; } = null!;
}
