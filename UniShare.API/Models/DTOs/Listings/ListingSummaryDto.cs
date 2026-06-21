namespace UniShare.API.Models.DTOs.Listings;

public class ListingSummaryDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = null!;
    public decimal PricePerDay { get; set; }
    public decimal? DepositAmount { get; set; }
    public string ListingType { get; set; } = null!;
    public string Status { get; set; } = null!;
    public string? CoverImageUrl { get; set; }
    public string? SchoolName { get; set; }
    public string? AreaName { get; set; }
    public string OwnerName { get; set; } = null!;
    public string? OwnerAvatarUrl { get; set; }
    public int UpvoteCount { get; set; }
    public int CommentCount { get; set; }
    public DateTime CreatedAt { get; set; }
}
