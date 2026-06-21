using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace UniShare.API.Tests.Helpers;

/// <summary>
/// Generates valid JWT tokens for test users without going through the login flow.
/// Tokens are signed with the same secret used by CustomWebApplicationFactory's test JWT config.
/// </summary>
public static class TestAuthHelper
{
    private static readonly SymmetricSecurityKey SigningKey =
        new(Encoding.UTF8.GetBytes(TestConstants.JwtSecret));

    /// <summary>
    /// Generates a valid JWT access token for the given user.
    /// </summary>
    public static string GenerateToken(Guid userId, string email, string role = Roles.User)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            new Claim(ClaimTypes.Email, email),
            new Claim(ClaimTypes.Role, role),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: TestConstants.JwtIssuer,
            audience: TestConstants.JwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(TestConstants.AccessTokenExpirationMinutes),
            signingCredentials: new SigningCredentials(SigningKey, SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    /// <summary>
    /// Generates an admin JWT token.
    /// </summary>
    public static string GenerateAdminToken(Guid adminUserId)
        => GenerateToken(adminUserId, TestConstants.AdminEmail, Roles.Admin);

    /// <summary>
    /// Sets the Authorization header on an HttpClient with a Bearer token.
    /// </summary>
    public static void SetAuthHeader(this HttpClient client, string token)
    {
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);
    }

    /// <summary>
    /// Generates an expired JWT token for security testing.
    /// </summary>
    public static string GenerateExpiredToken(Guid userId, string email)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            new Claim(ClaimTypes.Email, email),
            new Claim(ClaimTypes.Role, Roles.User),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: TestConstants.JwtIssuer,
            audience: TestConstants.JwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(-10), // Expired 10 minutes ago
            signingCredentials: new SigningCredentials(SigningKey, SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
