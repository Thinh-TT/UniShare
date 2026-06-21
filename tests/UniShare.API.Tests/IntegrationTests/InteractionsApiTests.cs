using UniShare.API.Tests.Helpers;
using UniShare.API.Tests.Infrastructure;
using Xunit.Abstractions;

namespace UniShare.API.Tests.IntegrationTests;

public class InteractionsApiTests : IntegrationTestBase
{
    public InteractionsApiTests(CustomWebApplicationFactory factory, ITestOutputHelper output)
        : base(factory, output) { }

    private static string UniqueEmail(string prefix = "int") =>
        $"{prefix}-{Guid.NewGuid():N}@unishare.edu.vn";

    private async Task<(HttpClient Client, Guid UserId)> CreateAuthUserAsync()
    {
        var email = UniqueEmail();
        const string password = "Test@123456";
        await Client.PostAsJsonAsync("/api/v1/auth/register",
            new { Email = email, Password = password, FullName = "Interaction User" });
        var loginResp = await Client.PostAsJsonAsync("/api/v1/auth/login",
            new { Login = email, Password = password });
        var login = await GetApiResponseAsync<LoginResponse>(loginResp);
        return (CreateAuthenticatedClient(login.Data!.User.Id, email), login.Data.User.Id);
    }

    private async Task<Guid> CreateListingAsync(HttpClient client)
    {
        var resp = await client.PostAsJsonAsync("/api/v1/listings", new
        {
            Title = "Listing for Interactions",
            Description = "Testing upvotes and comments",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m
        });
        resp.EnsureSuccessStatusCode();
        var apiResp = await GetApiResponseAsync<ListingDetailDto>(resp);
        return apiResp.Data!.Id;
    }

    [Fact]
    public async Task PUT_Upvote_FirstTime_Returns200()
    {
        var (client, _) = await CreateAuthUserAsync();
        var listingId = await CreateListingAsync(client);

        var response = await client.PutAsync($"/api/v1/listings/{listingId}/upvote", null);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task DELETE_RemoveUpvote_Returns200()
    {
        var (client, _) = await CreateAuthUserAsync();
        var listingId = await CreateListingAsync(client);
        await client.PutAsync($"/api/v1/listings/{listingId}/upvote", null);

        var response = await client.DeleteAsync($"/api/v1/listings/{listingId}/upvote");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task PUT_Upvote_WithoutAuth_Returns401()
    {
        var (client, _) = await CreateAuthUserAsync();
        var listingId = await CreateListingAsync(client);

        var response = await Client.PutAsync($"/api/v1/listings/{listingId}/upvote", null);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GET_Comments_Returns200()
    {
        var (client, _) = await CreateAuthUserAsync();
        var listingId = await CreateListingAsync(client);

        var response = await Client.GetAsync($"/api/v1/listings/{listingId}/comments");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task POST_CreateComment_Authenticated_Returns201()
    {
        var (client, _) = await CreateAuthUserAsync();
        var listingId = await CreateListingAsync(client);
        var payload = new { Content = "Great listing!" };

        var response = await client.PostAsJsonAsync(
            $"/api/v1/listings/{listingId}/comments", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
    }

    [Fact]
    public async Task POST_CreateComment_WithoutAuth_Returns401()
    {
        var (client, _) = await CreateAuthUserAsync();
        var listingId = await CreateListingAsync(client);
        var payload = new { Content = "Should fail" };

        var response = await Client.PostAsJsonAsync(
            $"/api/v1/listings/{listingId}/comments", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}
