using System.Text.Json;
using UniShare.API.Tests.Helpers;
using UniShare.API.Tests.Infrastructure;
using Xunit.Abstractions;

namespace UniShare.API.Tests.IntegrationTests;

public class ListingsApiTests : IntegrationTestBase
{
    public ListingsApiTests(CustomWebApplicationFactory factory, ITestOutputHelper output)
        : base(factory, output) { }

    private static string UniqueEmail(string prefix = "list") =>
        $"{prefix}-{Guid.NewGuid():N}@unishare.edu.vn";

    private async Task<(HttpClient Client, Guid UserId)> CreateAuthUserAsync()
    {
        var email = UniqueEmail();
        const string password = "Test@123456";
        var regResp = await Client.PostAsJsonAsync("/api/v1/auth/register",
            new { Email = email, Password = password, FullName = "Listing Owner" });
        regResp.EnsureSuccessStatusCode();

        var loginResp = await Client.PostAsJsonAsync("/api/v1/auth/login",
            new { Login = email, Password = password });
        var login = await GetApiResponseAsync<LoginResponse>(loginResp);
        var httpClient = CreateAuthenticatedClient(login.Data!.User.Id, email);
        return (httpClient, login.Data.User.Id);
    }

    [Fact]
    public async Task GET_Search_Default_Returns200()
    {
        var response = await Client.GetAsync("/api/v1/listings?page=1&pageSize=10");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await GetPagedResponseAsync<ListingSummaryDto>(response);
        result.Should().NotBeNull();
    }

    [Fact]
    public async Task GET_Search_NoResults_ReturnsEmpty()
    {
        var response = await Client.GetAsync("/api/v1/listings?keyword=zzzznonexistent12345");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await GetPagedResponseAsync<ListingSummaryDto>(response);
        result.Items.Should().BeEmpty();
    }

    [Fact]
    public async Task GET_ListingById_NotFound_Returns404()
    {
        var response = await Client.GetAsync($"/api/v1/listings/{Guid.NewGuid()}");
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task POST_CreateListing_Authenticated_Returns201()
    {
        var (client, _) = await CreateAuthUserAsync();
        var payload = new
        {
            Title = "Integration Test Laptop",
            Description = "A laptop for integration testing",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m,
            DepositAmount = 100000m
        };

        var response = await client.PostAsJsonAsync("/api/v1/listings", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var apiResponse = await GetApiResponseAsync<ListingDetailDto>(response);
        apiResponse.Data!.Title.Should().Be("Integration Test Laptop");
        apiResponse.Data.Status.Should().Be("Available");
    }

    [Fact]
    public async Task POST_CreateListing_WithoutAuth_Returns401()
    {
        var payload = new
        {
            Title = "Unauthorized Listing",
            Description = "Should fail",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m
        };

        var response = await Client.PostAsJsonAsync("/api/v1/listings", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task PUT_UpdateListing_NonOwner_Returns403()
    {
        var (ownerClient, _) = await CreateAuthUserAsync();
        // Create listing as owner
        var createPayload = new
        {
            Title = "Owner's Listing",
            Description = "For testing owner-only update",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m
        };
        var createResp = await ownerClient.PostAsJsonAsync("/api/v1/listings", createPayload);
        var created = await GetApiResponseAsync<ListingDetailDto>(createResp);
        var listingId = created.Data!.Id;

        // Create a second user (non-owner)
        var (otherClient, _) = await CreateAuthUserAsync();
        var updatePayload = new { Title = "Hacked Title" };

        var response = await otherClient.PutAsJsonAsync($"/api/v1/listings/{listingId}", updatePayload);

        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }
}
