using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Auth;
using UniShare.API.Models.DTOs.Users;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;
    private readonly JwtSettings _jwtSettings;

    public AuthService(
        AppDbContext context,
        IPasswordHasher passwordHasher,
        IJwtService jwtService,
        IOptions<JwtSettings> jwtSettings)
    {
        _context = context;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
        _jwtSettings = jwtSettings.Value;
    }

    public async Task<RegisterResponse> RegisterAsync(RegisterRequest request)
    {
        // Check duplicate email
        if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            throw new DuplicateEmailException("Email is already registered");

        // Check duplicate phone if provided
        if (!string.IsNullOrEmpty(request.PhoneNumber)
            && await _context.Users.AnyAsync(u => u.PhoneNumber == request.PhoneNumber))
            throw new DuplicatePhoneException("Phone number is already registered");

        var user = new User
        {
            Email = request.Email,
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = Roles.User,
            IsActive = true,
            ReputationScore = 100.00m
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return new RegisterResponse
        {
            UserId = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            ReputationScore = user.ReputationScore
        };
    }

    public async Task<LoginResponse> LoginAsync(LoginRequest request)
    {
        // Determine if login is email or phone
        var isEmail = request.Login.Contains('@');
        User? user;

        if (isEmail)
        {
            user = await _context.Users
                .Include(u => u.School)
                .Include(u => u.Area)
                .FirstOrDefaultAsync(u => u.Email == request.Login);
        }
        else
        {
            user = await _context.Users
                .Include(u => u.School)
                .Include(u => u.Area)
                .FirstOrDefaultAsync(u => u.PhoneNumber == request.Login);
        }

        // Generic error — do not reveal whether account exists
        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new InvalidCredentialsException("Invalid email/phone or password");

        if (!user.IsActive)
            throw new AccountInactiveException("Account has been deactivated");

        // Generate tokens
        var (accessToken, expiresAt) = _jwtService.GenerateAccessToken(user.Id, user.Email, user.Role);
        var refreshToken = _jwtService.GenerateRefreshToken();

        // Store refresh token in database
        var refreshTokenEntity = new RefreshToken
        {
            UserId = user.Id,
            Token = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays)
        };
        _context.RefreshTokens.Add(refreshTokenEntity);
        await _context.SaveChangesAsync();

        return new LoginResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresIn = (long)(expiresAt - DateTime.UtcNow).TotalSeconds,
            User = MapToSummary(user)
        };
    }

    public async Task<RefreshTokenResponse> RefreshTokenAsync(string refreshToken)
    {
        var storedToken = await _context.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

        if (storedToken is null || storedToken.IsRevoked || storedToken.ExpiresAt < DateTime.UtcNow)
            throw new InvalidRefreshTokenException("Invalid or expired refresh token");

        // Revoke old token (token rotation)
        storedToken.IsRevoked = true;
        storedToken.RevokedAt = DateTime.UtcNow;

        // Issue new tokens
        var (accessToken, expiresAt) = _jwtService.GenerateAccessToken(
            storedToken.UserId, storedToken.User.Email, storedToken.User.Role);
        var newRefreshToken = _jwtService.GenerateRefreshToken();

        var newRefreshTokenEntity = new RefreshToken
        {
            UserId = storedToken.UserId,
            Token = newRefreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpirationDays)
        };
        _context.RefreshTokens.Add(newRefreshTokenEntity);
        await _context.SaveChangesAsync();

        return new RefreshTokenResponse
        {
            AccessToken = accessToken,
            ExpiresIn = (long)(expiresAt - DateTime.UtcNow).TotalSeconds,
            RefreshToken = newRefreshToken
        };
    }

    public async Task LogoutAsync(Guid userId, string refreshToken)
    {
        var storedToken = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken && rt.UserId == userId);

        if (storedToken is not null && !storedToken.IsRevoked)
        {
            storedToken.IsRevoked = true;
            storedToken.RevokedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
        // Silently succeed even if token not found — logout is idempotent
    }

    private static UserSummaryDto MapToSummary(User user) => new()
    {
        Id = user.Id,
        Email = user.Email,
        FullName = user.FullName,
        AvatarUrl = user.AvatarUrl,
        ReputationScore = user.ReputationScore,
        TotalReviews = user.TotalReviews,
        SchoolName = user.School?.Name,
        AreaName = user.Area?.Name
    };
}
