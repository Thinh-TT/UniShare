namespace UniShare.API.Models.DTOs.Users;

public class UserProfileResponse
{
    public Guid Id { get; set; }
    public string Email { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string FullName { get; set; } = null!;
    public string? AvatarUrl { get; set; }
    public Guid? SchoolId { get; set; }
    public string? SchoolName { get; set; }
    public Guid? AreaId { get; set; }
    public string? AreaName { get; set; }
    public decimal ReputationScore { get; set; }
    public int TotalReviews { get; set; }
    public bool IsVerified { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
