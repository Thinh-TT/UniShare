namespace UniShare.API.Models.DTOs.Users;

public class UpdateProfileRequest
{
    public string? FullName { get; set; }
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }
    public Guid? SchoolId { get; set; }
    public Guid? AreaId { get; set; }
}
