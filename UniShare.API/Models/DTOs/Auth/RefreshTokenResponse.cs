namespace UniShare.API.Models.DTOs.Auth;

public class RefreshTokenResponse
{
    public string AccessToken { get; set; } = null!;
    /// <summary>Seconds until access token expires</summary>
    public long ExpiresIn { get; set; }
    public string RefreshToken { get; set; } = null!;
}
