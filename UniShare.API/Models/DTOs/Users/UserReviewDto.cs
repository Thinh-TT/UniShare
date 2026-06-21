namespace UniShare.API.Models.DTOs.Users;

public class UserReviewDto
{
    public Guid Id { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string ReviewerName { get; set; } = null!;
    public string? ReviewerAvatarUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}
