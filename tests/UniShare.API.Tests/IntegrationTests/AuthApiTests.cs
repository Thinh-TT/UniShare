using UniShare.API.Tests.Helpers;
using UniShare.API.Tests.Infrastructure;
using Xunit.Abstractions;

namespace UniShare.API.Tests.IntegrationTests;

public class AuthApiTests : IntegrationTestBase
{
    public AuthApiTests(CustomWebApplicationFactory factory, ITestOutputHelper output)
        : base(factory, output) { }

    // Helper to generate unique emails per test (avoids shared DB state issues)
    private static string UniqueEmail(string prefix = "test")
        => $"{prefix}-{Guid.NewGuid():N}@unishare.edu.vn";

    // ========================================================================
    // POST /api/v1/auth/register
    // ========================================================================

    [Fact]
    public async Task POST_Register_ValidUser_Returns201()
    {
        var email = UniqueEmail();
        var payload = new { Email = email, Password = "Test@123456", FullName = "Test User" };

        var response = await Client.PostAsJsonAsync("/api/v1/auth/register", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var apiResponse = await GetApiResponseAsync<RegisterResponse>(response);
        apiResponse.Data.Should().NotBeNull();
        apiResponse.Data!.Email.Should().Be(email);
    }

    [Fact]
    public async Task POST_Register_DuplicateEmail_Returns409()
    {
        var email = UniqueEmail("dup");
        var payload = new { Email = email, Password = "Test@123456", FullName = "Test User" };
        await Client.PostAsJsonAsync("/api/v1/auth/register", payload);

        var response = await Client.PostAsJsonAsync("/api/v1/auth/register", payload);

        await AssertProblemDetailsAsync(response, HttpStatusCode.Conflict);
    }

    [Fact]
    public async Task POST_Register_InvalidEmail_Returns400()
    {
        var payload = new { Email = "not-an-email", Password = "short", FullName = "" };

        var response = await Client.PostAsJsonAsync("/api/v1/auth/register", payload);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    // ========================================================================
    // POST /api/v1/auth/login
    // ========================================================================

    [Fact]
    public async Task POST_Login_ValidCredentials_Returns200()
    {
        var email = UniqueEmail("login");
        const string password = "Test@123456";
        await RegisterUserViaApiAsync(email, password);

        var payload = new { Login = email, Password = password };
        var response = await Client.PostAsJsonAsync("/api/v1/auth/login", payload);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var apiResponse = await GetApiResponseAsync<LoginResponse>(response);
        apiResponse.Data!.AccessToken.Should().NotBeNullOrEmpty();
        apiResponse.Data.RefreshToken.Should().NotBeNullOrEmpty();
        apiResponse.Data.User.Email.Should().Be(email);
    }

    [Fact]
    public async Task POST_Login_WrongPassword_Returns401()
    {
        var email = UniqueEmail("wrongpw");
        await RegisterUserViaApiAsync(email, "Correct@123");

        var payload = new { Login = email, Password = "WrongPass123!" };
        var response = await Client.PostAsJsonAsync("/api/v1/auth/login", payload);

        await AssertProblemDetailsAsync(response, HttpStatusCode.Unauthorized);
    }

    // ========================================================================
    // POST /api/v1/auth/refresh-token
    // ========================================================================

    [Fact]
    public async Task POST_RefreshToken_Valid_Returns200()
    {
        var email = UniqueEmail("refresher");
        await RegisterUserViaApiAsync(email);
        var loginResponse = await LoginViaApiAsync(email);

        var payload = new { RefreshToken = loginResponse.RefreshToken };
        var response = await Client.PostAsJsonAsync("/api/v1/auth/refresh-token", payload);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var apiResponse = await GetApiResponseAsync<RefreshTokenResponse>(response);
        apiResponse.Data!.AccessToken.Should().NotBeNullOrEmpty();
        apiResponse.Data.RefreshToken.Should().NotBe(loginResponse.RefreshToken);
    }

    // ========================================================================
    // POST /api/v1/auth/logout
    // ========================================================================

    [Fact]
    public async Task POST_Logout_Authenticated_Returns204()
    {
        var email = UniqueEmail("logout");
        await RegisterUserViaApiAsync(email);
        var loginResponse = await LoginViaApiAsync(email);
        var client = CreateAuthenticatedClient(loginResponse.User.Id, email);

        var payload = new { RefreshToken = loginResponse.RefreshToken };
        var response = await client.PostAsJsonAsync("/api/v1/auth/logout", payload);

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task POST_Logout_WithoutAuth_Returns401()
    {
        var payload = new { RefreshToken = "some-token" };

        var response = await Client.PostAsJsonAsync("/api/v1/auth/logout", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private async Task RegisterUserViaApiAsync(
        string email,
        string password = "Test@123456",
        string fullName = "Test User")
    {
        var payload = new { Email = email, Password = password, FullName = fullName };
        var response = await Client.PostAsJsonAsync("/api/v1/auth/register", payload);
        response.StatusCode.Should().Be(HttpStatusCode.Created,
            $"Register failed: {await response.Content.ReadAsStringAsync()}");
    }

    private async Task<LoginResponse> LoginViaApiAsync(
        string login,
        string password = "Test@123456")
    {
        var payload = new { Login = login, Password = password };
        var response = await Client.PostAsJsonAsync("/api/v1/auth/login", payload);
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var apiResponse = await GetApiResponseAsync<LoginResponse>(response);
        return apiResponse.Data!;
    }
}
