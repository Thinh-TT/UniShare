namespace UniShare.API.Tests.Helpers;

/// <summary>
/// Centralized constants for test data matching the seed data from SeedData.cs.
/// </summary>
public static class TestConstants
{
    // ========================================================================
    // Seed Data GUIDs (must match SeedData.cs exactly)
    // ========================================================================

    // Schools
    public static readonly Guid HustSchoolId = Guid.Parse("10000000-0000-0000-0000-000000000001");
    public static readonly Guid VnuSchoolId = Guid.Parse("10000000-0000-0000-0000-000000000002");

    // Areas
    public static readonly Guid MyDinhAreaId = Guid.Parse("20000000-0000-0000-0000-000000000001");
    public static readonly Guid CauGiayAreaId = Guid.Parse("20000000-0000-0000-0000-000000000002");

    // Categories
    public static readonly Guid ElectronicsCategoryId = Guid.Parse("30000000-0000-0000-0000-000000000009");
    public static readonly Guid CalculatorCategoryId = Guid.Parse("30000000-0000-0000-0000-000000000001");
    public static readonly Guid BookCategoryId = Guid.Parse("30000000-0000-0000-0000-000000000002");

    // Tags
    public static readonly Guid LaptopTagId = Guid.Parse("40000000-0000-0000-0000-000000000008");
    public static readonly Guid CasioTagId = Guid.Parse("40000000-0000-0000-0000-000000000001");

    // ========================================================================
    // Test User Credentials
    // ========================================================================
    public const string TestEmail = "testuser@unishare.edu.vn";
    public const string TestPassword = "Test@123456";
    public const string TestPhone = "0912345678";
    public const string TestFullName = "Test User";

    public const string SecondEmail = "seconduser@unishare.edu.vn";
    public const string SecondPassword = "Test@654321";
    public const string SecondPhone = "0987654321";
    public const string SecondFullName = "Second User";

    // ========================================================================
    // Admin (matching appsettings.Development.json)
    // ========================================================================
    public const string AdminEmail = "admin@unishare.edu.vn";
    public const string AdminPassword = "Admin@123456!";

    // ========================================================================
    // JWT Settings (must match what CustomWebApplicationFactory injects)
    // ========================================================================
    public const string JwtSecret = "UniShare-Test-Secret-Key-At-Least-32-Chars-Long!";
    public const string JwtIssuer = "UniShare";
    public const string JwtAudience = "UniShare-Test";
    public const int AccessTokenExpirationMinutes = 60;
    public const int RefreshTokenExpirationDays = 7;
}
