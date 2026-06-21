using UniShare.API.Tests.Helpers;

namespace UniShare.API.Tests.UnitTests.Services;

public class ReviewServiceTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly IReviewService _reviewService;
    private readonly Mock<INotificationService> _notificationMock;

    public ReviewServiceTests()
    {
        var dbName = $"ReviewTest_{Guid.NewGuid():N}";
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite($"DataSource=file:{dbName}?mode=memory&cache=shared")
            .Options;

        _context = new AppDbContext(options);
        _context.Database.OpenConnection();
        _context.Database.EnsureCreated();

        _notificationMock = new Mock<INotificationService>();
        _reviewService = new ReviewService(_context, _notificationMock.Object);
    }

    public void Dispose()
    {
        _context.Database.CloseConnection();
        _context.Dispose();
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private async Task<User> CreateUserAsync(string email, string fullName, decimal reputationScore = 100.00m)
    {
        var user = TestDataFactory.CreateUser(
            email: email, fullName: fullName, reputationScore: reputationScore);
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    private async Task<(User Owner, User Requester, Listing Listing, RentalRequest Request)>
        CreateCompletedRentalAsync()
    {
        var owner = await CreateUserAsync(TestConstants.TestEmail, TestConstants.TestFullName);
        var requester = await CreateUserAsync(TestConstants.SecondEmail, TestConstants.SecondFullName);

        var listing = TestDataFactory.CreateListing(
            ownerId: owner.Id,
            categoryId: TestConstants.ElectronicsCategoryId,
            status: ListingStatus.Available);
        _context.Listings.Add(listing);
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing.Id));
        await _context.SaveChangesAsync();

        var request = TestDataFactory.CreateRentalRequest(
            listingId: listing.Id,
            requesterId: requester.Id,
            ownerId: owner.Id,
            status: RequestStatus.Completed);
        _context.RentalRequests.Add(request);

        // Set up navigation properties for the review service
        await _context.Entry(request).Reference(r => r.Requester).LoadAsync();
        await _context.Entry(request).Reference(r => r.Owner).LoadAsync();

        await _context.SaveChangesAsync();

        return (owner, requester, listing, request);
    }

    // ========================================================================
    // Valid Review Tests
    // ========================================================================

    [Fact]
    public async Task CreateReview_ValidReview_ShouldCreateReview()
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var dto = new CreateReviewRequest { Rating = 5, Comment = "Great experience!" };

        // Act - requester reviews owner
        var result = await _reviewService.CreateReviewAsync(request.Id, requester.Id, dto);

        // Assert
        result.Should().NotBeNull();
        result.Rating.Should().Be(5);
        result.Comment.Should().Be("Great experience!");
        result.ReviewerId.Should().Be(requester.Id);
        result.ReputationDelta.Should().Be(20m); // (5-3)*10
    }

    [Fact]
    public async Task CreateReview_ShouldNotifyReviewee()
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var dto = new CreateReviewRequest { Rating = 4, Comment = "Good" };

        // Act
        await _reviewService.CreateReviewAsync(request.Id, requester.Id, dto);

        // Assert
        _notificationMock.Verify(
            n => n.CreateNotificationAsync(
                owner.Id,
                NotificationType.Review,
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<Guid>(),
                "Review"),
            Times.Once);
    }

    [Fact]
    public async Task CreateReview_OwnerCanReviewRequester()
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var dto = new CreateReviewRequest { Rating = 3 };

        // Act - owner reviews requester
        var result = await _reviewService.CreateReviewAsync(request.Id, owner.Id, dto);

        // Assert
        result.ReviewerId.Should().Be(owner.Id);
        result.ReputationDelta.Should().Be(0m);
    }

    // ========================================================================
    // Non-Completed Status Tests
    // ========================================================================

    [Theory]
    [InlineData(RequestStatus.Pending)]
    [InlineData(RequestStatus.Accepted)]
    [InlineData(RequestStatus.InProgress)]
    [InlineData(RequestStatus.Rejected)]
    [InlineData(RequestStatus.Cancelled)]
    public async Task CreateReview_NonCompletedStatus_ShouldThrow409(RequestStatus status)
    {
        // Arrange
        var owner = await CreateUserAsync(TestConstants.TestEmail, "Owner");
        var requester = await CreateUserAsync(TestConstants.SecondEmail, "Requester");
        var listing = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId);
        _context.Listings.Add(listing);
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing.Id));
        await _context.SaveChangesAsync();

        var request = TestDataFactory.CreateRentalRequest(
            listingId: listing.Id,
            requesterId: requester.Id,
            ownerId: owner.Id,
            status: status);
        _context.RentalRequests.Add(request);
        await _context.Entry(request).Reference(r => r.Requester).LoadAsync();
        await _context.Entry(request).Reference(r => r.Owner).LoadAsync();
        await _context.SaveChangesAsync();

        var dto = new CreateReviewRequest { Rating = 5 };

        // Act
        var act = () => _reviewService.CreateReviewAsync(request.Id, requester.Id, dto);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>()
            .Where(ex => ex.StatusCode == 409);
    }

    // ========================================================================
    // Duplicate Review Test
    // ========================================================================

    [Fact]
    public async Task CreateReview_DuplicateReviewer_ShouldThrow409()
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var dto = new CreateReviewRequest { Rating = 5 };
        await _reviewService.CreateReviewAsync(request.Id, requester.Id, dto);

        // Act
        var act = () => _reviewService.CreateReviewAsync(request.Id, requester.Id,
            new CreateReviewRequest { Rating = 1 });

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    // ========================================================================
    // Non-Participant Test
    // ========================================================================

    [Fact]
    public async Task CreateReview_NonParticipant_ShouldThrow403()
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var outsider = await CreateUserAsync("outsider@test.com", "Outsider");
        var dto = new CreateReviewRequest { Rating = 5 };

        // Act
        var act = () => _reviewService.CreateReviewAsync(request.Id, outsider.Id, dto);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    // ========================================================================
    // Reputation Score Tests
    // ========================================================================

    [Theory]
    [InlineData(1, -20)]
    [InlineData(2, -10)]
    [InlineData(3, 0)]
    [InlineData(4, 10)]
    [InlineData(5, 20)]
    public async Task CreateReview_ReputationDelta_ShouldBeCorrect(int rating, decimal expectedDelta)
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var dto = new CreateReviewRequest { Rating = rating };

        // Act
        var result = await _reviewService.CreateReviewAsync(request.Id, requester.Id, dto);

        // Assert
        result.ReputationDelta.Should().Be(expectedDelta);
    }

    [Fact]
    public async Task CreateReview_ShouldUpdateRevieweeReputationScore()
    {
        // Arrange
        var owner = await CreateUserAsync(TestConstants.TestEmail, "Owner", reputationScore: 100m);
        var requester = await CreateUserAsync(TestConstants.SecondEmail, "Requester");
        var listing = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId);
        _context.Listings.Add(listing);
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing.Id));
        await _context.SaveChangesAsync();

        var request = TestDataFactory.CreateRentalRequest(
            listing.Id, requester.Id, owner.Id, RequestStatus.Completed);
        _context.RentalRequests.Add(request);
        await _context.Entry(request).Reference(r => r.Requester).LoadAsync();
        await _context.Entry(request).Reference(r => r.Owner).LoadAsync();
        await _context.SaveChangesAsync();

        // Act - requester gives owner 5 stars → +20
        await _reviewService.CreateReviewAsync(request.Id, requester.Id,
            new CreateReviewRequest { Rating = 5 });

        // Assert
        await _context.Entry(owner).ReloadAsync();
        owner.ReputationScore.Should().Be(120m);
        owner.TotalReviews.Should().Be(1);
    }

    [Fact]
    public async Task CreateReview_ReputationClampedAtZero_ShouldNotGoNegative()
    {
        // Arrange
        var owner = await CreateUserAsync(TestConstants.TestEmail, "Owner", reputationScore: 10m);
        var requester = await CreateUserAsync(TestConstants.SecondEmail, "Requester");
        var listing = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId);
        _context.Listings.Add(listing);
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing.Id));
        await _context.SaveChangesAsync();

        var request = TestDataFactory.CreateRentalRequest(
            listing.Id, requester.Id, owner.Id, RequestStatus.Completed);
        _context.RentalRequests.Add(request);
        await _context.Entry(request).Reference(r => r.Requester).LoadAsync();
        await _context.Entry(request).Reference(r => r.Owner).LoadAsync();
        await _context.SaveChangesAsync();

        // Act - requester gives owner 1 star → -20, should clamp to 0
        await _reviewService.CreateReviewAsync(request.Id, requester.Id,
            new CreateReviewRequest { Rating = 1 });

        // Assert
        await _context.Entry(owner).ReloadAsync();
        owner.ReputationScore.Should().Be(0m); // Clamped at 0
    }

    [Fact]
    public async Task CreateReview_ShouldIncrementTotalReviews()
    {
        // Arrange
        var (owner, requester, listing, request) = await CreateCompletedRentalAsync();
        var dto = new CreateReviewRequest { Rating = 3 };

        // Act
        await _reviewService.CreateReviewAsync(request.Id, requester.Id, dto);

        // Assert
        await _context.Entry(owner).ReloadAsync();
        owner.TotalReviews.Should().Be(1);
    }
}
