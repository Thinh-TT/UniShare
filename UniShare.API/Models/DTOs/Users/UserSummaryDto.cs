namespace UniShare.API.Models.DTOs.Users;

public class UserSummaryDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string? AvatarUrl { get; set; }
    public decimal ReputationScore { get; set; }
    public int TotalReviews { get; set; }
    public string? SchoolName { get; set; }
    public string? AreaName { get; set; }
}
