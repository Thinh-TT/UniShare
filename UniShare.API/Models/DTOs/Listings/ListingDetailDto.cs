using TagDto = UniShare.API.Models.DTOs.Metadata.TagDto;

namespace UniShare.API.Models.DTOs.Listings;

public class ListingDetailDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public decimal PricePerDay { get; set; }
    public decimal? DepositAmount { get; set; }
    public string? ConditionNote { get; set; }
    public string ListingType { get; set; } = null!;
    public string Status { get; set; } = null!;
    public string CategoryName { get; set; } = null!;
    public string? SchoolName { get; set; }
    public string? AreaName { get; set; }
    public int ViewCount { get; set; }
    public int UpvoteCount { get; set; }
    public int CommentCount { get; set; }
    public Guid OwnerId { get; set; }
    public string OwnerName { get; set; } = null!;
    public string? OwnerAvatarUrl { get; set; }
    public int OwnerReputationScore { get; set; }
    public List<ListingImageDto> Images { get; set; } = new();
    public List<TagDto> Tags { get; set; } = new();
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
