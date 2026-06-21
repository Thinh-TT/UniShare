using UniShare.API.Services.Interfaces;

namespace UniShare.API.Tests.Helpers;

/// <summary>
/// Static factory methods to create test entity instances and seed test databases.
/// </summary>
public static class TestDataFactory
{
    private static readonly IPasswordHasher _passwordHasher = new PasswordHasher();

    // ========================================================================
    // Entity Builders
    // ========================================================================

    public static User CreateUser(
        string email = TestConstants.TestEmail,
        string password = TestConstants.TestPassword,
        string fullName = TestConstants.TestFullName,
        string? phone = null,
        string role = Roles.User,
        bool isActive = true,
        decimal reputationScore = 100.00m,
        int totalReviews = 0,
        Guid? schoolId = null,
        Guid? areaId = null)
    {
        return new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            PasswordHash = _passwordHasher.Hash(password),
            FullName = fullName,
            PhoneNumber = phone,
            Role = role,
            IsActive = isActive,
            IsVerified = true,
            ReputationScore = reputationScore,
            TotalReviews = totalReviews,
            SchoolId = schoolId,
            AreaId = areaId,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Listing CreateListing(
        Guid ownerId,
        Guid categoryId,
        string title = "Test Listing",
        string description = "A test listing for unit tests",
        ListingType listingType = ListingType.Rent,
        ListingStatus status = ListingStatus.Available,
        decimal pricePerDay = 50000m,
        decimal? depositAmount = null,
        Guid? schoolId = null,
        Guid? areaId = null,
        int viewCount = 0,
        int upvoteCount = 0,
        int commentCount = 0)
    {
        return new Listing
        {
            Id = Guid.NewGuid(),
            OwnerId = ownerId,
            CategoryId = categoryId,
            SchoolId = schoolId,
            AreaId = areaId,
            Title = title,
            Description = description,
            ListingType = listingType,
            Status = status,
            PricePerDay = listingType == ListingType.Borrow ? 0 : pricePerDay,
            DepositAmount = depositAmount,
            ViewCount = viewCount,
            UpvoteCount = upvoteCount,
            CommentCount = commentCount,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static ListingImage CreateListingImage(
        Guid listingId,
        string imageUrl = "https://example.com/image.jpg",
        bool isCover = true,
        int displayOrder = 1)
    {
        return new ListingImage
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            ImageUrl = imageUrl,
            IsCover = isCover,
            DisplayOrder = displayOrder,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static RentalRequest CreateRentalRequest(
        Guid listingId,
        Guid requesterId,
        Guid ownerId,
        RequestStatus status = RequestStatus.Pending,
        DateTime? startDate = null,
        DateTime? endDate = null,
        decimal totalPrice = 50000m,
        decimal? depositAmount = null,
        string? message = null)
    {
        var today = DateTime.UtcNow.Date;
        return new RentalRequest
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            RequesterId = requesterId,
            OwnerId = ownerId,
            Status = status,
            StartDate = startDate ?? today.AddDays(1),
            EndDate = endDate ?? today.AddDays(3),
            TotalPrice = totalPrice,
            DepositAmount = depositAmount,
            Message = message,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Review CreateReview(
        Guid rentalRequestId,
        Guid reviewerId,
        Guid revieweeId,
        int rating,
        string? comment = null)
    {
        var delta = (rating - 3) * 10m;
        return new Review
        {
            Id = Guid.NewGuid(),
            RentalRequestId = rentalRequestId,
            ReviewerId = reviewerId,
            RevieweeId = revieweeId,
            Rating = rating,
            Comment = comment,
            ReputationDelta = delta,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Conversation CreateConversation(
        Guid listingId,
        Guid ownerId,
        Guid requesterId,
        Guid? rentalRequestId = null)
    {
        return new Conversation
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            OwnerId = ownerId,
            RequesterId = requesterId,
            RentalRequestId = rentalRequestId,
            LastMessageAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Deposit CreateDeposit(
        Guid rentalRequestId,
        decimal amount,
        DepositStatus status = DepositStatus.Pending)
    {
        return new Deposit
        {
            Id = Guid.NewGuid(),
            RentalRequestId = rentalRequestId,
            Amount = amount,
            Status = status,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static RefreshToken CreateRefreshToken(
        Guid userId,
        string token,
        bool isRevoked = false,
        DateTime? expiresAt = null)
    {
        return new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Token = token,
            IsRevoked = isRevoked,
            ExpiresAt = expiresAt ?? DateTime.UtcNow.AddDays(7),
            CreatedAt = DateTime.UtcNow
        };
    }

    // ========================================================================
    // Database Seeding
    // ========================================================================

    /// <summary>
    /// Seeds baseline test data on top of the seed data from SeedData.cs
    /// (which runs via OnModelCreating). Creates test user and admin.
    /// </summary>
    public static async Task SeedTestUsersAsync(AppDbContext context)
    {
        // Create test user if not exists
        if (!await context.Users.AnyAsync(u => u.Email == TestConstants.TestEmail))
        {
            var user = CreateUser();
            context.Users.Add(user);
        }

        // Create second test user if not exists
        if (!await context.Users.AnyAsync(u => u.Email == TestConstants.SecondEmail))
        {
            var secondUser = CreateUser(
                email: TestConstants.SecondEmail,
                password: TestConstants.SecondPassword,
                fullName: TestConstants.SecondFullName,
                phone: TestConstants.SecondPhone);
            context.Users.Add(secondUser);
        }

        await context.SaveChangesAsync();
    }

    /// <summary>
    /// Seeds an admin user for admin endpoint tests.
    /// </summary>
    public static async Task<User> SeedAdminUserAsync(AppDbContext context)
    {
        var admin = await context.Users
            .FirstOrDefaultAsync(u => u.Email == TestConstants.AdminEmail);

        if (admin is null)
        {
            admin = CreateUser(
                email: TestConstants.AdminEmail,
                password: TestConstants.AdminPassword,
                fullName: "System Administrator",
                role: Roles.Admin);
            context.Users.Add(admin);
            await context.SaveChangesAsync();
        }

        return admin;
    }
}
