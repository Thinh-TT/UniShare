namespace UniShare.API.Models.DTOs.Auth;

public class LoginRequest
{
    /// <summary>Email address or phone number</summary>
    public string Login { get; set; } = null!;
    public string Password { get; set; } = null!;
}
