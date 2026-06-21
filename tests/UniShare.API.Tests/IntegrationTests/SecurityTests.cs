using UniShare.API.Tests.Helpers;
using UniShare.API.Tests.Infrastructure;
using Xunit.Abstractions;

namespace UniShare.API.Tests.IntegrationTests;

/// <summary>
/// Security tests verifying 401 Unauthorized and 403 Forbidden on protected endpoints.
/// </summary>
public class SecurityTests : IntegrationTestBase
{
    public SecurityTests(CustomWebApplicationFactory factory, ITestOutputHelper output)
        : base(factory, output) { }

    private static string UniqueEmail(string prefix = "sec") =>
        $"{prefix}-{Guid.NewGuid():N}@unishare.edu.vn";

    // ========================================================================
    // 401 Unauthorized — No token
    // ========================================================================

    [Fact] public async Task GET_Users_Me_NoToken_Returns401()
    {
        var r = await Client.GetAsync("/api/v1/users/me");
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact] public async Task POST_Listings_NoToken_Returns401()
    {
        var r = await Client.PostAsJsonAsync("/api/v1/listings", new { });
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact] public async Task PUT_Upvote_NoToken_Returns401()
    {
        var r = await Client.PutAsync($"/api/v1/listings/{Guid.NewGuid()}/upvote", null);
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact] public async Task POST_CreateConversation_NoToken_Returns401()
    {
        var r = await Client.PostAsJsonAsync($"/api/v1/listings/{Guid.NewGuid()}/conversations", new { });
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact] public async Task POST_RentalRequest_NoToken_Returns401()
    {
        var r = await Client.PostAsJsonAsync(
            $"/api/v1/listings/{Guid.NewGuid()}/rental-requests", new { });
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact] public async Task GET_Notifications_NoToken_Returns401()
    {
        var r = await Client.GetAsync("/api/v1/me/notifications");
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    // ========================================================================
    // 401 Unauthorized — Invalid/Expired token
    // ========================================================================

    [Fact]
    public async Task ProtectedEndpoint_InvalidToken_Returns401()
    {
        var client = Factory.CreateClient();
        client.SetAuthHeader("invalid-token-here");

        var r = await client.GetAsync("/api/v1/users/me");
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ProtectedEndpoint_ExpiredToken_Returns401()
    {
        var client = Factory.CreateClient();
        var expiredToken = TestAuthHelper.GenerateExpiredToken(Guid.NewGuid(), "test@test.com");
        client.SetAuthHeader(expiredToken);

        var r = await client.GetAsync("/api/v1/users/me");
        r.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    // ========================================================================
    // 403 Forbidden — Admin endpoints as regular user
    // ========================================================================

    [Fact]
    public async Task AdminEndpoints_AsRegularUser_Returns403()
    {
        var (userClient, _) = await CreateAuthUserAsync();

        var r = await userClient.PostAsJsonAsync("/api/v1/admin/schools", new
        {
            Name = "Test School",
            ShortName = "TS",
            City = "Test City"
        });
        r.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task AdminEndpoints_AsAdmin_Returns201()
    {
        // Seed admin user in test DB
        var admin = await Helpers.TestDataFactory.SeedAdminUserAsync(Factory.CreateDbContext());
        var adminClient = Factory.CreateAdminClient(admin.Id);

        var r = await adminClient.PostAsJsonAsync("/api/v1/admin/categories", new
        {
            Name = "Test Category",
            Slug = "test-category",
            Description = "A test category"
        });
        r.StatusCode.Should().Be(HttpStatusCode.Created);
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private async Task<(HttpClient Client, Guid UserId)> CreateAuthUserAsync()
    {
        var email = UniqueEmail();
        const string password = "Test@123456";
        await Client.PostAsJsonAsync("/api/v1/auth/register",
            new { Email = email, Password = password, FullName = "Security Test User" });
        var loginResp = await Client.PostAsJsonAsync("/api/v1/auth/login",
            new { Login = email, Password = password });
        var login = await GetApiResponseAsync<LoginResponse>(loginResp);
        return (CreateAuthenticatedClient(login.Data!.User.Id, email), login.Data.User.Id);
    }
}
