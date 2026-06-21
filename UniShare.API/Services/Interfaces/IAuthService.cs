using UniShare.API.Models.DTOs.Auth;

namespace UniShare.API.Services.Interfaces;

public interface IAuthService
{
    Task<RegisterResponse> RegisterAsync(RegisterRequest request);
    Task<LoginResponse> LoginAsync(LoginRequest request);
    Task<RefreshTokenResponse> RefreshTokenAsync(string refreshToken);
    Task LogoutAsync(Guid userId, string refreshToken);
}
