using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using UniShare.API.Tests.Helpers;

namespace UniShare.API.Tests.Infrastructure;

/// <summary>
/// Custom WebApplicationFactory that replaces SQL Server with SQLite in-memory
/// and configures JWT for testing purposes.
/// </summary>
public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly string _dbName = $"UniShare_Test_{Guid.NewGuid():N}";

    public CustomWebApplicationFactory()
    {
        // Ensure database is created once per factory instance
        using var scope = Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        try
        {
            context.Database.EnsureCreated();
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                $"Failed to create SQLite in-memory database. " +
                $"Ensure all entity configurations are compatible with SQLite. Error: {ex.Message}", ex);
        }
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        // Use "Test" environment to skip admin seeding in Program.cs
        builder.UseEnvironment("Test");

        builder.ConfigureAppConfiguration((context, config) =>
        {
            // Override JWT settings so TestAuthHelper tokens are accepted
            config.AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Jwt:SecretKey"] = Helpers.TestConstants.JwtSecret,
                ["Jwt:Issuer"] = Helpers.TestConstants.JwtIssuer,
                ["Jwt:Audience"] = Helpers.TestConstants.JwtAudience,
                ["Jwt:AccessTokenExpirationMinutes"] = "60",
                ["Jwt:RefreshTokenExpirationDays"] = "7"
            });
        });

        builder.ConfigureServices(services =>
        {
            // Remove the SQL Server DbContext registration
            services.RemoveAll<DbContextOptions<AppDbContext>>();
            services.RemoveAll<AppDbContext>();

            // Add SQLite in-memory
            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlite($"DataSource=file:{_dbName}?mode=memory&cache=shared");
            });

            // Rebuild service provider so the new DbContext is used
            var sp = services.BuildServiceProvider();
        });
    }

    /// <summary>
    /// Creates an HttpClient with a pre-configured JWT Authorization header.
    /// </summary>
    public HttpClient CreateAuthenticatedClient(Guid userId, string email, string role = Roles.User)
    {
        var client = CreateClient();
        var token = Helpers.TestAuthHelper.GenerateToken(userId, email, role);
        client.SetAuthHeader(token);
        return client;
    }

    /// <summary>
    /// Creates an HttpClient with an admin JWT token.
    /// </summary>
    public HttpClient CreateAdminClient(Guid adminUserId)
    {
        var client = CreateClient();
        var token = Helpers.TestAuthHelper.GenerateAdminToken(adminUserId);
        client.SetAuthHeader(token);
        return client;
    }

    /// <summary>
    /// Returns a fresh AppDbContext for direct database access in test setup/verification.
    /// </summary>
    public AppDbContext CreateDbContext()
    {
        var scope = Services.CreateScope();
        return scope.ServiceProvider.GetRequiredService<AppDbContext>();
    }

    /// <summary>
    /// Shortcut to get a service from the DI container.
    /// </summary>
    public TService GetService<TService>() where TService : notnull
    {
        using var scope = Services.CreateScope();
        return scope.ServiceProvider.GetRequiredService<TService>();
    }
}
