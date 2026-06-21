using UniShare.API.Models.DTOs.Deposits;

namespace UniShare.API.Models.DTOs.RentalRequests;

public class RentalRequestDetailDto
{
    public Guid Id { get; set; }
    public string Status { get; set; } = null!;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string? Message { get; set; }
    public decimal TotalPrice { get; set; }
    public decimal? DepositAmount { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    // Listing
    public Guid ListingId { get; set; }
    public string ListingTitle { get; set; } = null!;
    public string? ListingImageUrl { get; set; }
    public decimal ListingPricePerDay { get; set; }
    public string ListingType { get; set; } = null!;

    // Requester
    public Guid RequesterId { get; set; }
    public string RequesterName { get; set; } = null!;
    public string? RequesterAvatarUrl { get; set; }

    // Owner
    public Guid OwnerId { get; set; }
    public string OwnerName { get; set; } = null!;
    public string? OwnerAvatarUrl { get; set; }

    // Deposit (null if no deposit record exists yet)
    public DepositDto? Deposit { get; set; }
}
