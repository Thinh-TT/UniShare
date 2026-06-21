namespace UniShare.API.Models.DTOs.RentalRequests;

public class RentalRequestSummaryDto
{
    public Guid Id { get; set; }
    public string Status { get; set; } = null!;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal TotalPrice { get; set; }
    public decimal? DepositAmount { get; set; }
    public DateTime CreatedAt { get; set; }

    // Listing info
    public Guid ListingId { get; set; }
    public string ListingTitle { get; set; } = null!;
    public string? ListingImageUrl { get; set; }

    // Counterpart (the other participant from the viewer's perspective)
    public Guid OtherParticipantId { get; set; }
    public string OtherParticipantName { get; set; } = null!;
    public string? OtherParticipantAvatarUrl { get; set; }

    /// <summary>"requester" or "owner" — the viewer's role in this request.</summary>
    public string Role { get; set; } = null!;
}
