using UniShare.API.Tests.Helpers;
using UniShare.API.Tests.Infrastructure;
using Xunit.Abstractions;

namespace UniShare.API.Tests.IntegrationTests;

public class UsersApiTests : IntegrationTestBase
{
    public UsersApiTests(CustomWebApplicationFactory factory, ITestOutputHelper output)
        : base(factory, output) { }

    private static string UniqueEmail(string prefix = "user") =>
        $"{prefix}-{Guid.NewGuid():N}@unishare.edu.vn";

    private async Task<(string email, string password, Guid userId)> RegisterAndLoginAsync()
    {
        var email = UniqueEmail();
        const string password = "Test@123456";
        var regPayload = new { Email = email, Password = password, FullName = "Profile User" };
        var regResp = await Client.PostAsJsonAsync("/api/v1/auth/register", regPayload);
        regResp.StatusCode.Should().Be(HttpStatusCode.Created);

        var loginPayload = new { Login = email, Password = password };
        var loginResp = await Client.PostAsJsonAsync("/api/v1/auth/login", loginPayload);
        var apiResp = await GetApiResponseAsync<LoginResponse>(loginResp);
        return (email, password, apiResp.Data!.User.Id);
    }

    [Fact]
    public async Task GET_Me_Authenticated_Returns200()
    {
        var (email, _, userId) = await RegisterAndLoginAsync();
        var client = CreateAuthenticatedClient(userId, email);

        var response = await client.GetAsync("/api/v1/users/me");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var apiResponse = await GetApiResponseAsync<UserProfileResponse>(response);
        apiResponse.Data!.Email.Should().Be(email);
    }

    [Fact]
    public async Task GET_Me_WithoutAuth_Returns401()
    {
        var response = await Client.GetAsync("/api/v1/users/me");
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GET_UserById_ValidId_Returns200()
    {
        var (email, _, userId) = await RegisterAndLoginAsync();
        var client = CreateAuthenticatedClient(userId, email);

        var response = await client.GetAsync($"/api/v1/users/{userId}");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task GET_UserById_NotFound_Returns404()
    {
        var (email, _, userId) = await RegisterAndLoginAsync();
        var client = CreateAuthenticatedClient(userId, email);

        var response = await client.GetAsync($"/api/v1/users/{Guid.NewGuid()}");

        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }
}
