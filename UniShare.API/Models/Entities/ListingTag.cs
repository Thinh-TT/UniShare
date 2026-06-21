namespace UniShare.API.Models.Entities;

public class ListingTag
{
    public Guid ListingId { get; set; }
    public Guid TagId { get; set; }

    // Navigation properties
    public Listing Listing { get; set; } = null!;
    public Tag Tag { get; set; } = null!;
}
