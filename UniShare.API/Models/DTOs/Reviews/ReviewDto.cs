namespace UniShare.API.Models.DTOs.Reviews;

public class ReviewDto
{
    public Guid Id { get; set; }
    public Guid RentalRequestId { get; set; }
    public Guid ReviewerId { get; set; }
    public string ReviewerName { get; set; } = null!;
    public string? ReviewerAvatarUrl { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public decimal ReputationDelta { get; set; }
    public DateTime CreatedAt { get; set; }
}
