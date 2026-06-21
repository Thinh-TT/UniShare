namespace UniShare.API.Models.DTOs.Listings;

public class ReorderImagesRequest
{
    public List<Guid> ImageIds { get; set; } = new();
}
