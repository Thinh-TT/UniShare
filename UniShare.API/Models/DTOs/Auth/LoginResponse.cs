using UniShare.API.Models.DTOs.Users;

namespace UniShare.API.Models.DTOs.Auth;

public class LoginResponse
{
    public string AccessToken { get; set; } = null!;
    public string RefreshToken { get; set; } = null!;
    /// <summary>Seconds until access token expires</summary>
    public long ExpiresIn { get; set; }
    public UserSummaryDto User { get; set; } = null!;
}
