namespace UniShare.API.Models.DTOs.Listings;

public class ListingImageDto
{
    public Guid Id { get; set; }
    public string ImageUrl { get; set; } = null!;
    public int DisplayOrder { get; set; }
    public bool IsCover { get; set; }
}
