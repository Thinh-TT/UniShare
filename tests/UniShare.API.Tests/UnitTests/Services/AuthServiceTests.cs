using Microsoft.Extensions.Options;
using UniShare.API.Tests.Helpers;

namespace UniShare.API.Tests.UnitTests.Services;

public class AuthServiceTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly IAuthService _authService;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;

    public AuthServiceTests()
    {
        var dbName = $"AuthTest_{Guid.NewGuid():N}";
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite($"DataSource=file:{dbName}?mode=memory&cache=shared")
            .Options;

        _context = new AppDbContext(options);

        // EnsureCreated runs migrations from scratch; SeedData runs via OnModelCreating
        // We need to open the connection manually so the in-memory DB persists
        _context.Database.OpenConnection();
        _context.Database.EnsureCreated();

        _passwordHasher = new PasswordHasher();
        _jwtService = new JwtService(Options.Create(new JwtSettings
        {
            SecretKey = TestConstants.JwtSecret,
            Issuer = TestConstants.JwtIssuer,
            Audience = TestConstants.JwtAudience,
            AccessTokenExpirationMinutes = TestConstants.AccessTokenExpirationMinutes,
            RefreshTokenExpirationDays = TestConstants.RefreshTokenExpirationDays
        }));
        _authService = new AuthService(_context, _passwordHasher, _jwtService,
            Options.Create(new JwtSettings
            {
                SecretKey = TestConstants.JwtSecret,
                Issuer = TestConstants.JwtIssuer,
                Audience = TestConstants.JwtAudience,
                AccessTokenExpirationMinutes = TestConstants.AccessTokenExpirationMinutes,
                RefreshTokenExpirationDays = TestConstants.RefreshTokenExpirationDays
            }));
    }

    public void Dispose()
    {
        _context.Database.CloseConnection();
        _context.Dispose();
    }

    // ========================================================================
    // RegisterAsync Tests
    // ========================================================================

    [Fact]
    public async Task RegisterAsync_ValidRequest_ShouldCreateUser()
    {
        // Arrange
        var request = new RegisterRequest
        {
            Email = TestConstants.TestEmail,
            Password = TestConstants.TestPassword,
            FullName = TestConstants.TestFullName,
            PhoneNumber = TestConstants.TestPhone
        };

        // Act
        var result = await _authService.RegisterAsync(request);

        // Assert
        result.Should().NotBeNull();
        result.Email.Should().Be(TestConstants.TestEmail);
        result.FullName.Should().Be(TestConstants.TestFullName);
        result.ReputationScore.Should().Be(100.00m);
        result.UserId.Should().NotBeEmpty();

        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == TestConstants.TestEmail);
        user.Should().NotBeNull();
        user!.Role.Should().Be(Roles.User);
        user.IsActive.Should().BeTrue();
        user.PasswordHash.Should().NotBe(TestConstants.TestPassword); // Hashed
    }

    [Fact]
    public async Task RegisterAsync_DuplicateEmail_ShouldThrow409()
    {
        // Arrange
        var request = new RegisterRequest
        {
            Email = TestConstants.TestEmail,
            Password = TestConstants.TestPassword,
            FullName = TestConstants.TestFullName
        };
        await _authService.RegisterAsync(request);

        // Act
        var act = () => _authService.RegisterAsync(request);

        // Assert
        await act.Should().ThrowAsync<DuplicateEmailException>()
            .Where(ex => ex.StatusCode == 409);
    }

    [Fact]
    public async Task RegisterAsync_DuplicatePhone_ShouldThrow409()
    {
        // Arrange
        var first = new RegisterRequest
        {
            Email = "first@test.com",
            Password = TestConstants.TestPassword,
            FullName = "First User",
            PhoneNumber = TestConstants.TestPhone
        };
        await _authService.RegisterAsync(first);

        var second = new RegisterRequest
        {
            Email = "second@test.com",
            Password = TestConstants.TestPassword,
            FullName = "Second User",
            PhoneNumber = TestConstants.TestPhone
        };

        // Act
        var act = () => _authService.RegisterAsync(second);

        // Assert
        await act.Should().ThrowAsync<DuplicatePhoneException>()
            .Where(ex => ex.StatusCode == 409);
    }

    [Fact]
    public async Task RegisterAsync_WithoutPhone_ShouldSucceed()
    {
        // Arrange
        var request = new RegisterRequest
        {
            Email = "nophone@test.com",
            Password = TestConstants.TestPassword,
            FullName = "No Phone User"
        };

        // Act
        var result = await _authService.RegisterAsync(request);

        // Assert
        result.Should().NotBeNull();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == "nophone@test.com");
        user!.PhoneNumber.Should().BeNull();
    }

    // ========================================================================
    // LoginAsync Tests
    // ========================================================================

    [Fact]
    public async Task LoginAsync_WithEmail_ShouldReturnTokens()
    {
        // Arrange
        await RegisterTestUserAsync();
        var request = new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = TestConstants.TestPassword
        };

        // Act
        var result = await _authService.LoginAsync(request);

        // Assert
        result.Should().NotBeNull();
        result.AccessToken.Should().NotBeNullOrEmpty();
        result.RefreshToken.Should().NotBeNullOrEmpty();
        result.ExpiresIn.Should().BeGreaterThan(0);
        result.User.Should().NotBeNull();
        result.User.Email.Should().Be(TestConstants.TestEmail);
        result.User.FullName.Should().Be(TestConstants.TestFullName);
    }

    [Fact]
    public async Task LoginAsync_WithPhone_ShouldReturnTokens()
    {
        // Arrange
        await RegisterTestUserAsync();
        var request = new LoginRequest
        {
            Login = TestConstants.TestPhone,
            Password = TestConstants.TestPassword
        };

        // Act
        var result = await _authService.LoginAsync(request);

        // Assert
        result.Should().NotBeNull();
        result.AccessToken.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task LoginAsync_InvalidPassword_ShouldThrow401()
    {
        // Arrange
        await RegisterTestUserAsync();
        var request = new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = "WrongPassword123!"
        };

        // Act
        var act = () => _authService.LoginAsync(request);

        // Assert
        await act.Should().ThrowAsync<InvalidCredentialsException>()
            .Where(ex => ex.StatusCode == 401);
    }

    [Fact]
    public async Task LoginAsync_NonexistentEmail_ShouldThrow401()
    {
        // Arrange
        var request = new LoginRequest
        {
            Login = "nobody@test.com",
            Password = TestConstants.TestPassword
        };

        // Act
        var act = () => _authService.LoginAsync(request);

        // Assert
        await act.Should().ThrowAsync<InvalidCredentialsException>()
            .Where(ex => ex.StatusCode == 401);
    }

    [Fact]
    public async Task LoginAsync_InactiveAccount_ShouldThrow403()
    {
        // Arrange
        await RegisterTestUserAsync();
        var user = await _context.Users.FirstAsync(u => u.Email == TestConstants.TestEmail);
        user.IsActive = false;
        await _context.SaveChangesAsync();

        var request = new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = TestConstants.TestPassword
        };

        // Act
        var act = () => _authService.LoginAsync(request);

        // Assert
        await act.Should().ThrowAsync<AccountInactiveException>()
            .Where(ex => ex.StatusCode == 403);
    }

    [Fact]
    public async Task LoginAsync_ShouldStoreRefreshTokenInDatabase()
    {
        // Arrange
        await RegisterTestUserAsync();
        var request = new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = TestConstants.TestPassword
        };

        // Act
        var result = await _authService.LoginAsync(request);

        // Assert
        var storedToken = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == result.RefreshToken);
        storedToken.Should().NotBeNull();
        storedToken!.IsRevoked.Should().BeFalse();
        storedToken.ExpiresAt.Should().BeAfter(DateTime.UtcNow);
    }

    // ========================================================================
    // RefreshTokenAsync Tests
    // ========================================================================

    [Fact]
    public async Task RefreshTokenAsync_ValidToken_ShouldReturnNewTokens()
    {
        // Arrange
        await RegisterTestUserAsync();
        var loginResult = await _authService.LoginAsync(new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = TestConstants.TestPassword
        });

        // Act
        var result = await _authService.RefreshTokenAsync(loginResult.RefreshToken);

        // Assert
        result.Should().NotBeNull();
        result.AccessToken.Should().NotBeNullOrEmpty();
        result.RefreshToken.Should().NotBeNullOrEmpty();
        result.RefreshToken.Should().NotBe(loginResult.RefreshToken); // Rotation

        // Old token should be revoked
        var oldToken = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == loginResult.RefreshToken);
        oldToken!.IsRevoked.Should().BeTrue();
        oldToken.RevokedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task RefreshTokenAsync_ExpiredToken_ShouldThrow401()
    {
        // Arrange
        await RegisterTestUserAsync();
        var user = await _context.Users.FirstAsync(u => u.Email == TestConstants.TestEmail);
        var expiredToken = TestDataFactory.CreateRefreshToken(
            user.Id, "expired-token", expiresAt: DateTime.UtcNow.AddDays(-1));
        _context.RefreshTokens.Add(expiredToken);
        await _context.SaveChangesAsync();

        // Act
        var act = () => _authService.RefreshTokenAsync("expired-token");

        // Assert
        await act.Should().ThrowAsync<InvalidRefreshTokenException>()
            .Where(ex => ex.StatusCode == 401);
    }

    [Fact]
    public async Task RefreshTokenAsync_RevokedToken_ShouldThrow401()
    {
        // Arrange
        await RegisterTestUserAsync();
        var user = await _context.Users.FirstAsync(u => u.Email == TestConstants.TestEmail);
        var revokedToken = TestDataFactory.CreateRefreshToken(
            user.Id, "revoked-token", isRevoked: true);
        _context.RefreshTokens.Add(revokedToken);
        await _context.SaveChangesAsync();

        // Act
        var act = () => _authService.RefreshTokenAsync("revoked-token");

        // Assert
        await act.Should().ThrowAsync<InvalidRefreshTokenException>()
            .Where(ex => ex.StatusCode == 401);
    }

    [Fact]
    public async Task RefreshTokenAsync_NonexistentToken_ShouldThrow401()
    {
        // Act
        var act = () => _authService.RefreshTokenAsync("nonexistent-token");

        // Assert
        await act.Should().ThrowAsync<InvalidRefreshTokenException>()
            .Where(ex => ex.StatusCode == 401);
    }

    // ========================================================================
    // LogoutAsync Tests
    // ========================================================================

    [Fact]
    public async Task LogoutAsync_ValidToken_ShouldRevoke()
    {
        // Arrange
        await RegisterTestUserAsync();
        var loginResult = await _authService.LoginAsync(new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = TestConstants.TestPassword
        });
        var user = await _context.Users.FirstAsync(u => u.Email == TestConstants.TestEmail);

        // Act
        await _authService.LogoutAsync(user.Id, loginResult.RefreshToken);

        // Assert
        var storedToken = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == loginResult.RefreshToken);
        storedToken!.IsRevoked.Should().BeTrue();
        storedToken.RevokedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task LogoutAsync_NonexistentToken_ShouldSucceedSilently()
    {
        // Arrange
        await RegisterTestUserAsync();
        var user = await _context.Users.FirstAsync(u => u.Email == TestConstants.TestEmail);

        // Act
        var act = () => _authService.LogoutAsync(user.Id, "nonexistent-token");

        // Assert - should not throw
        await act.Should().NotThrowAsync();
    }

    [Fact]
    public async Task LogoutAsync_AlreadyRevokedToken_ShouldSucceedSilently()
    {
        // Arrange
        await RegisterTestUserAsync();
        var loginResult = await _authService.LoginAsync(new LoginRequest
        {
            Login = TestConstants.TestEmail,
            Password = TestConstants.TestPassword
        });
        var user = await _context.Users.FirstAsync(u => u.Email == TestConstants.TestEmail);
        await _authService.LogoutAsync(user.Id, loginResult.RefreshToken); // First logout

        // Act
        var act = () => _authService.LogoutAsync(user.Id, loginResult.RefreshToken);

        // Assert
        await act.Should().NotThrowAsync();
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private async Task RegisterTestUserAsync(
        string email = TestConstants.TestEmail,
        string password = TestConstants.TestPassword,
        string fullName = TestConstants.TestFullName,
        string? phone = TestConstants.TestPhone)
    {
        await _authService.RegisterAsync(new RegisterRequest
        {
            Email = email,
            Password = password,
            FullName = fullName,
            PhoneNumber = phone
        });
    }
}
