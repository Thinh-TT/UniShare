namespace UniShare.API.Models.DTOs.Interactions;

public class UpvoteResponse
{
    public Guid ListingId { get; set; }
    public bool IsUpvoted { get; set; }
    public int UpvoteCount { get; set; }
}
