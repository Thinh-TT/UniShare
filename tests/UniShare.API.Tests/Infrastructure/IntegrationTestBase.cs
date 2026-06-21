using Microsoft.Extensions.DependencyInjection;
using UniShare.API.Tests.Helpers;
using Xunit.Abstractions;

namespace UniShare.API.Tests.Infrastructure;

/// <summary>
/// Base class for integration tests providing common setup, authentication helpers,
/// and response deserialization utilities.
/// </summary>
public abstract class IntegrationTestBase : IClassFixture<CustomWebApplicationFactory>, IDisposable
{
    protected readonly CustomWebApplicationFactory Factory;
    protected readonly HttpClient Client;
    protected readonly ITestOutputHelper Output;

    protected IntegrationTestBase(CustomWebApplicationFactory factory, ITestOutputHelper output)
    {
        Factory = factory;
        Output = output;
        Client = factory.CreateClient();
    }

    // ========================================================================
    // Authenticated client helpers
    // ========================================================================

    /// <summary>
    /// Creates an HttpClient authenticated as the given user.
    /// </summary>
    protected HttpClient CreateAuthenticatedClient(Guid userId, string email, string role = Roles.User)
        => Factory.CreateAuthenticatedClient(userId, email, role);

    /// <summary>
    /// Creates an HttpClient authenticated as an admin.
    /// </summary>
    protected HttpClient CreateAdminClient(Guid adminUserId)
        => Factory.CreateAdminClient(adminUserId);

    // ========================================================================
    // User creation helper
    // ========================================================================

    /// <summary>
    /// Creates a test user in the database and returns their ID and the raw entity.
    /// </summary>
    protected async Task<(Guid UserId, User User)> CreateTestUserInDbAsync(
        string email = Helpers.TestConstants.TestEmail,
        string password = Helpers.TestConstants.TestPassword,
        string fullName = Helpers.TestConstants.TestFullName,
        string? phone = Helpers.TestConstants.TestPhone,
        string role = Roles.User)
    {
        using var scope = Factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var user = Helpers.TestDataFactory.CreateUser(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
            role: role);

        context.Users.Add(user);
        await context.SaveChangesAsync();

        return (user.Id, user);
    }

    // ========================================================================
    // Response deserialization helpers
    // ========================================================================

    /// <summary>
    /// Deserializes a successful (200/201) response that was wrapped by ResponseWrapperFilter.
    /// </summary>
    protected static async Task<ApiResponse<T>> GetApiResponseAsync<T>(HttpResponseMessage response)
    {
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<ApiResponse<T>>();
        result.Should().NotBeNull();
        return result!;
    }

    /// <summary>
    /// Deserializes a paged response.
    /// </summary>
    protected static async Task<PagedResponse<T>> GetPagedResponseAsync<T>(HttpResponseMessage response)
    {
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<PagedResponse<T>>();
        result.Should().NotBeNull();
        return result!;
    }

    /// <summary>
    /// Asserts the response is a ProblemDetails error with the expected status code.
    /// </summary>
    protected static async Task AssertProblemDetailsAsync(
        HttpResponseMessage response, HttpStatusCode expectedStatus, string? expectedDetail = null)
    {
        response.StatusCode.Should().Be(expectedStatus);
        response.Content.Headers.ContentType?.MediaType.Should().Be("application/problem+json");

        var problem = await response.Content.ReadFromJsonAsync<ProblemDetails>();
        problem.Should().NotBeNull();
        problem!.Status.Should().Be((int)expectedStatus);

        if (expectedDetail is not null)
            problem.Detail.Should().Contain(expectedDetail);
    }

    /// <summary>
    /// Bare-bones ProblemDetails for deserialization in tests.
    /// </summary>
    protected class ProblemDetails
    {
        public string? Type { get; set; }
        public string? Title { get; set; }
        public int Status { get; set; }
        public string? Detail { get; set; }
        public string? Instance { get; set; }
    }

    // ========================================================================
    // Database reset
    // ========================================================================

    public virtual void Dispose()
    {
        Client.Dispose();
    }
}
