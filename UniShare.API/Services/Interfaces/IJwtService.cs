using System.Security.Claims;

namespace UniShare.API.Services.Interfaces;

public interface IJwtService
{
    (string accessToken, DateTime expiresAt) GenerateAccessToken(Guid userId, string email, string role);
    string GenerateRefreshToken();
    ClaimsPrincipal? ValidateToken(string token);
}
