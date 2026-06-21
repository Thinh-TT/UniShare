namespace UniShare.API.Models.DTOs.Auth;

public class RegisterResponse
{
    public Guid UserId { get; set; }
    public string Email { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public decimal ReputationScore { get; set; }
}
