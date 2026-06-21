using UniShare.API.Tests.Helpers;
using UniShare.API.Tests.Infrastructure;
using Xunit.Abstractions;

namespace UniShare.API.Tests.IntegrationTests;

/// <summary>
/// End-to-end rental flow integration tests covering the full lifecycle:
/// register -> listing -> request -> accept -> start -> complete -> review
/// </summary>
public class RentalFlowTests : IntegrationTestBase
{
    public RentalFlowTests(CustomWebApplicationFactory factory, ITestOutputHelper output)
        : base(factory, output) { }

    private static string UniqueEmail(string prefix) =>
        $"{prefix}-{Guid.NewGuid():N}@unishare.edu.vn";

    private async Task<(HttpClient Client, Guid UserId, string Email)> RegisterAndLoginAsync(string prefix)
    {
        var email = UniqueEmail(prefix);
        const string password = "Test@123456";
        await Client.PostAsJsonAsync("/api/v1/auth/register",
            new { Email = email, Password = password, FullName = $"User {prefix}" });
        var loginResp = await Client.PostAsJsonAsync("/api/v1/auth/login",
            new { Login = email, Password = password });
        var login = await GetApiResponseAsync<LoginResponse>(loginResp);
        var httpClient = CreateAuthenticatedClient(login.Data!.User.Id, email);
        return (httpClient, login.Data.User.Id, email);
    }

    private async Task<Guid> CreateListingAsync(HttpClient client, decimal pricePerDay = 50000m,
        decimal? depositAmount = null)
    {
        var resp = await client.PostAsJsonAsync("/api/v1/listings", new
        {
            Title = "Rental Test Item",
            Description = "Item for rental flow testing",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = pricePerDay,
            DepositAmount = depositAmount
        });
        resp.EnsureSuccessStatusCode();
        var apiResp = await GetApiResponseAsync<ListingDetailDto>(resp);
        return apiResp.Data!.Id;
    }

    [Fact]
    public async Task FullRentalFlow_HappyPath_ShouldComplete()
    {
        // 1. Owner creates listing
        var (ownerClient, ownerId, _) = await RegisterAndLoginAsync("owner");
        var listingId = await CreateListingAsync(ownerClient, pricePerDay: 50000m, depositAmount: 50000m);

        // 2. Requester creates rental request
        var (requesterClient, requesterId, _) = await RegisterAndLoginAsync("renter");
        var createReq = new
        {
            StartDate = DateTime.UtcNow.Date.AddDays(1),
            EndDate = DateTime.UtcNow.Date.AddDays(3),
            Message = "I'd like to rent this"
        };
        var reqResp = await requesterClient.PostAsJsonAsync(
            $"/api/v1/listings/{listingId}/rental-requests", createReq);
        reqResp.EnsureSuccessStatusCode();
        var reqApi = await GetApiResponseAsync<RentalRequestDetailDto>(reqResp);
        var requestId = reqApi.Data!.Id;
        reqApi.Data.Status.Should().Be("Pending");

        // 3. Owner accepts request
        var acceptResp = await ownerClient.PatchAsync(
            $"/api/v1/rental-requests/{requestId}/accept", null);
        acceptResp.EnsureSuccessStatusCode();
        var acceptApi = await GetApiResponseAsync<RentalRequestDetailDto>(acceptResp);
        acceptApi.Data.Status.Should().Be("Accepted");

        // 4. Owner starts transaction
        var startResp = await ownerClient.PatchAsync(
            $"/api/v1/rental-requests/{requestId}/start", null);
        startResp.EnsureSuccessStatusCode();
        var startApi = await GetApiResponseAsync<RentalRequestDetailDto>(startResp);
        startApi.Data.Status.Should().Be("InProgress");

        // 5. Requester completes transaction
        var completeResp = await requesterClient.PatchAsync(
            $"/api/v1/rental-requests/{requestId}/complete", null);
        completeResp.EnsureSuccessStatusCode();
        var completeApi = await GetApiResponseAsync<RentalRequestDetailDto>(completeResp);
        completeApi.Data.Status.Should().Be("Completed");

        // 6. Requester reviews owner (5 stars)
        var reviewResp = await requesterClient.PostAsJsonAsync(
            $"/api/v1/rental-requests/{requestId}/reviews",
            new { Rating = 5, Comment = "Excellent!" });
        reviewResp.StatusCode.Should().Be(HttpStatusCode.Created);

        // 7. Owner reviews requester (4 stars)
        var review2Resp = await ownerClient.PostAsJsonAsync(
            $"/api/v1/rental-requests/{requestId}/reviews",
            new { Rating = 4, Comment = "Good renter" });
        review2Resp.StatusCode.Should().Be(HttpStatusCode.Created);
    }

    [Fact]
    public async Task RentalFlow_Rejection_ShouldWork()
    {
        var (ownerClient, ownerId, _) = await RegisterAndLoginAsync("rejowner");
        var (requesterClient, requesterId, _) = await RegisterAndLoginAsync("rejrenter");
        var listingId = await CreateListingAsync(ownerClient);

        // Create request
        var reqResp = await requesterClient.PostAsJsonAsync(
            $"/api/v1/listings/{listingId}/rental-requests",
            new { StartDate = DateTime.UtcNow.Date.AddDays(1), EndDate = DateTime.UtcNow.Date.AddDays(3) });
        var reqApi = await GetApiResponseAsync<RentalRequestDetailDto>(reqResp);

        // Owner rejects
        var rejectResp = await ownerClient.PatchAsync(
            $"/api/v1/rental-requests/{reqApi.Data!.Id}/reject", null);
        rejectResp.EnsureSuccessStatusCode();
        var rejectApi = await GetApiResponseAsync<RentalRequestDetailDto>(rejectResp);
        rejectApi.Data.Status.Should().Be("Rejected");
    }

    [Fact]
    public async Task RentalFlow_CancelBeforeAccept_ShouldWork()
    {
        var (ownerClient, _, _) = await RegisterAndLoginAsync("canowner");
        var (requesterClient, _, _) = await RegisterAndLoginAsync("canrenter");
        var listingId = await CreateListingAsync(ownerClient);

        var reqResp = await requesterClient.PostAsJsonAsync(
            $"/api/v1/listings/{listingId}/rental-requests",
            new { StartDate = DateTime.UtcNow.Date.AddDays(1), EndDate = DateTime.UtcNow.Date.AddDays(3) });
        var reqApi = await GetApiResponseAsync<RentalRequestDetailDto>(reqResp);

        var cancelResp = await requesterClient.PatchAsync(
            $"/api/v1/rental-requests/{reqApi.Data!.Id}/cancel", null);
        cancelResp.EnsureSuccessStatusCode();
        var cancelApi = await GetApiResponseAsync<RentalRequestDetailDto>(cancelResp);
        cancelApi.Data.Status.Should().Be("Cancelled");
    }

    [Fact]
    public async Task RentalFlow_Notifications_ShouldExist()
    {
        var (ownerClient, ownerId, _) = await RegisterAndLoginAsync("notiowner");
        var (requesterClient, _, _) = await RegisterAndLoginAsync("notirenter");
        var listingId = await CreateListingAsync(ownerClient);

        // Create request (triggers notification for owner)
        var reqResp = await requesterClient.PostAsJsonAsync(
            $"/api/v1/listings/{listingId}/rental-requests",
            new { StartDate = DateTime.UtcNow.Date.AddDays(1), EndDate = DateTime.UtcNow.Date.AddDays(3) });
        reqResp.EnsureSuccessStatusCode();

        // Owner should have notifications
        var notifResp = await ownerClient.GetAsync("/api/v1/me/notifications");
        notifResp.EnsureSuccessStatusCode();
        var notifPaged = await GetPagedResponseAsync<NotificationDto>(notifResp);
        notifPaged.Items.Should().NotBeEmpty();
    }
}
