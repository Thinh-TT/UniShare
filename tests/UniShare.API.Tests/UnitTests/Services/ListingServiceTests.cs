using UniShare.API.Tests.Helpers;

namespace UniShare.API.Tests.UnitTests.Services;

public class ListingServiceTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly IListingService _listingService;

    public ListingServiceTests()
    {
        var dbName = $"ListingTest_{Guid.NewGuid():N}";
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite($"DataSource=file:{dbName}?mode=memory&cache=shared")
            .Options;

        _context = new AppDbContext(options);
        _context.Database.OpenConnection();
        _context.Database.EnsureCreated();

        _listingService = new ListingService(_context);
    }

    public void Dispose()
    {
        _context.Database.CloseConnection();
        _context.Dispose();
    }

    // ========================================================================
    // Helper - Create test user and listing
    // ========================================================================

    private async Task<User> CreateTestOwnerAsync(
        string email = TestConstants.TestEmail,
        string fullName = TestConstants.TestFullName)
    {
        var user = TestDataFactory.CreateUser(email: email, fullName: fullName);
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    private async Task<(User Owner, Listing Listing)> CreateTestListingAsync(
        ListingType listingType = ListingType.Rent,
        decimal pricePerDay = 50000m,
        decimal? depositAmount = 100000m,
        ListingStatus status = ListingStatus.Available)
    {
        var owner = await CreateTestOwnerAsync();

        // Add a cover image so the listing is valid
        var listing = TestDataFactory.CreateListing(
            ownerId: owner.Id,
            categoryId: TestConstants.ElectronicsCategoryId,
            listingType: listingType,
            pricePerDay: pricePerDay,
            depositAmount: depositAmount,
            status: status);
        _context.Listings.Add(listing);

        var image = TestDataFactory.CreateListingImage(listing.Id);
        _context.ListingImages.Add(image);

        await _context.SaveChangesAsync();

        // Reload with navigation properties
        await _context.Entry(listing).Collection(l => l.Images).LoadAsync();

        return (owner, listing);
    }

    // ========================================================================
    // CreateListingAsync Tests
    // ========================================================================

    [Fact]
    public async Task CreateListingAsync_ValidRequest_ShouldCreateAvailableListing()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var request = new CreateListingRequest
        {
            Title = "Test Laptop",
            Description = "A test laptop for rent",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m,
            DepositAmount = 100000m
        };

        // Act
        var result = await _listingService.CreateListingAsync(owner.Id, request);

        // Assert
        result.Should().NotBeNull();
        result.Title.Should().Be("Test Laptop");
        result.Status.Should().Be("Available");
        result.PricePerDay.Should().Be(50000m);
        result.OwnerId.Should().Be(owner.Id);
        result.DepositAmount.Should().Be(100000m);
    }

    [Fact]
    public async Task CreateListingAsync_BorrowType_ShouldForcePriceToZero()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var request = new CreateListingRequest
        {
            Title = "Test Borrow Item",
            Description = "Item to borrow",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Borrow",
            PricePerDay = 50000m // Should be forced to 0
        };

        // Act
        var result = await _listingService.CreateListingAsync(owner.Id, request);

        // Assert
        result.PricePerDay.Should().Be(0);
    }

    [Fact]
    public async Task CreateListingAsync_InactiveCategory_ShouldThrow404()
    {
        // Arrange - create an inactive category directly
        var inactiveCat = new Category
        {
            Id = Guid.NewGuid(),
            Name = "Inactive Cat",
            Slug = "inactive-cat",
            IsActive = false,
            CreatedAt = DateTime.UtcNow
        };
        _context.Categories.Add(inactiveCat);
        await _context.SaveChangesAsync();

        var owner = await CreateTestOwnerAsync();
        var request = new CreateListingRequest
        {
            Title = "Test",
            Description = "Test",
            CategoryId = inactiveCat.Id,
            ListingType = "Rent",
            PricePerDay = 50000m
        };

        // Act
        var act = () => _listingService.CreateListingAsync(owner.Id, request);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>();
    }

    [Fact]
    public async Task CreateListingAsync_NonexistentOwner_ShouldThrow404()
    {
        // Arrange
        var request = new CreateListingRequest
        {
            Title = "Test",
            Description = "Test",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m
        };

        // Act
        var act = () => _listingService.CreateListingAsync(Guid.NewGuid(), request);

        // Assert
        await act.Should().ThrowAsync<NotFoundException>();
    }

    [Fact]
    public async Task CreateListingAsync_InvalidListingType_ShouldThrow409()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var request = new CreateListingRequest
        {
            Title = "Test",
            Description = "Test",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Invalid",
            PricePerDay = 50000m
        };

        // Act
        var act = () => _listingService.CreateListingAsync(owner.Id, request);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>()
            .Where(ex => ex.StatusCode == 409);
    }

    [Fact]
    public async Task CreateListingAsync_WithTags_ShouldCreateListingTags()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var request = new CreateListingRequest
        {
            Title = "Tagged Listing",
            Description = "Listing with tags",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m,
            TagNames = new List<string> { "test-tag", "another-tag" }
        };

        // Act
        var result = await _listingService.CreateListingAsync(owner.Id, request);

        // Assert - verify unique tag slugs (accounting for EF Core relationship fixup)
        result.Tags.Select(t => t.Slug).Distinct().Should().BeEquivalentTo(
            new[] { "test-tag", "another-tag" });
    }

    [Fact]
    public async Task CreateListingAsync_WithSchoolAndArea_ShouldPersist()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var request = new CreateListingRequest
        {
            Title = "School Listing",
            Description = "Listing at HUST",
            CategoryId = TestConstants.ElectronicsCategoryId,
            ListingType = "Rent",
            PricePerDay = 50000m,
            SchoolId = TestConstants.HustSchoolId,
            AreaId = TestConstants.MyDinhAreaId
        };

        // Act
        var result = await _listingService.CreateListingAsync(owner.Id, request);

        // Assert
        result.SchoolName.Should().NotBeNull();
        result.AreaName.Should().NotBeNull();
    }

    // ========================================================================
    // UpdateListingAsync Tests
    // ========================================================================

    [Fact]
    public async Task UpdateListingAsync_Owner_ShouldUpdateFields()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();
        var request = new UpdateListingRequest
        {
            Title = "Updated Title",
            Description = "Updated description"
        };

        // Act
        var result = await _listingService.UpdateListingAsync(listing.Id, owner.Id, request);

        // Assert
        result.Title.Should().Be("Updated Title");
        result.Description.Should().Be("Updated description");
    }

    [Fact]
    public async Task UpdateListingAsync_NonOwner_ShouldThrow403()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();
        var otherUser = await CreateTestOwnerAsync(TestConstants.SecondEmail, TestConstants.SecondFullName);
        var request = new UpdateListingRequest { Title = "Hacked" };

        // Act
        var act = () => _listingService.UpdateListingAsync(listing.Id, otherUser.Id, request);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>()
            .Where(ex => ex.StatusCode == 403);
    }

    [Fact]
    public async Task UpdateListingAsync_BorrowTypeWithPrice_ShouldThrow409()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync(ListingType.Borrow);
        // Load category
        await _context.Entry(listing).Reference(l => l.Category).LoadAsync();
        await _context.Entry(listing).Reference(l => l.Owner).LoadAsync();
        var request = new UpdateListingRequest { PricePerDay = 50000m };

        // Act
        var act = () => _listingService.UpdateListingAsync(listing.Id, owner.Id, request);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>()
            .Where(ex => ex.StatusCode == 409);
    }

    [Fact]
    public async Task UpdateListingAsync_WithTags_ShouldReplaceTags()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();
        var request = new UpdateListingRequest
        {
            TagNames = new List<string> { "updated-tag" }
        };

        // Act
        var result = await _listingService.UpdateListingAsync(listing.Id, owner.Id, request);

        // Assert
        result.Tags.Should().HaveCount(1);
        result.Tags[0].Slug.Should().Be("updated-tag");
    }

    // ========================================================================
    // CloseListingAsync Tests
    // ========================================================================

    [Fact]
    public async Task CloseListingAsync_Owner_ShouldSetStatusClosed()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();

        // Act
        await _listingService.CloseListingAsync(listing.Id, owner.Id);

        // Assert
        await _context.Entry(listing).ReloadAsync();
        listing.Status.Should().Be(ListingStatus.Closed);
    }

    [Fact]
    public async Task CloseListingAsync_NonOwner_ShouldThrow403()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();
        var otherUser = await CreateTestOwnerAsync(TestConstants.SecondEmail, TestConstants.SecondFullName);

        // Act
        var act = () => _listingService.CloseListingAsync(listing.Id, otherUser.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    // ========================================================================
    // SoftDeleteListingAsync Tests
    // ========================================================================

    [Fact]
    public async Task SoftDeleteListingAsync_Owner_ShouldSetDeletedAt()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();

        // Act
        await _listingService.SoftDeleteListingAsync(listing.Id, owner.Id);

        // Assert - reload outside of global query filter
        var deleted = await _context.Listings.IgnoreQueryFilters()
            .FirstOrDefaultAsync(l => l.Id == listing.Id);
        deleted!.DeletedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task SoftDeleteListingAsync_NonOwner_ShouldThrow403()
    {
        // Arrange
        var (owner, listing) = await CreateTestListingAsync();
        var otherUser = await CreateTestOwnerAsync(TestConstants.SecondEmail, TestConstants.SecondFullName);

        // Act
        var act = () => _listingService.SoftDeleteListingAsync(listing.Id, otherUser.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    // ========================================================================
    // SearchListingsAsync Tests
    // ========================================================================

    [Theory]
    [InlineData("Test Listing", 1)]  // matches title
    [InlineData("unit tests", 1)]    // matches description
    [InlineData("zzzznonexistent", 0)]
    public async Task SearchListingsAsync_Keyword_ShouldFilter(string keyword, int expectedCount)
    {
        // Arrange
        var (owner, _) = await CreateTestListingAsync();
        var filters = new ListingFilterParams { Keyword = keyword, Page = 1, PageSize = 20 };

        // Act
        var result = await _listingService.SearchListingsAsync(filters);

        // Assert
        result.Items.Count.Should().Be(expectedCount);
    }

    [Fact]
    public async Task SearchListingsAsync_ShouldOnlyReturnAvailable()
    {
        // Arrange
        var (owner, available) = await CreateTestListingAsync(status: ListingStatus.Available);
        var draft = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId,
            status: ListingStatus.Draft, title: "Draft Listing");
        _context.Listings.Add(draft);
        await _context.SaveChangesAsync();

        // Act
        var result = await _listingService.SearchListingsAsync(new ListingFilterParams());

        // Assert
        result.Items.Should().ContainSingle(l => l.Id == available.Id);
        result.Items.Should().NotContain(l => l.Id == draft.Id);
    }

    [Fact]
    public async Task SearchListingsAsync_Pagination_ShouldReturnCorrectPage()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        for (int i = 0; i < 25; i++)
        {
            var listing = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId,
                title: $"Listing {i:D2}");
            _context.Listings.Add(listing);
            var image = TestDataFactory.CreateListingImage(listing.Id);
            _context.ListingImages.Add(image);
        }
        await _context.SaveChangesAsync();

        // Act - page 1
        var page1 = await _listingService.SearchListingsAsync(new ListingFilterParams { Page = 1, PageSize = 10 });

        // Assert
        page1.Items.Should().HaveCount(10);
        page1.Page.Should().Be(1);
        page1.TotalItems.Should().Be(25);

        // Act - page 3
        var page3 = await _listingService.SearchListingsAsync(new ListingFilterParams { Page = 3, PageSize = 10 });
        page3.Items.Should().HaveCount(5); // Last page
    }

    [Fact]
    public async Task SearchListingsAsync_SortByUpvotes_ShouldOrderCorrectly()
    {
        // Note: SQLite does not support ORDER BY decimal (price), so we test upvote sort (int)
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var listing1 = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId,
            pricePerDay: 10000m, title: "Low Vote", upvoteCount: 1);
        var listing2 = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId,
            pricePerDay: 50000m, title: "High Vote", upvoteCount: 10);
        _context.Listings.AddRange(listing1, listing2);
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing1.Id));
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing2.Id));
        await _context.SaveChangesAsync();

        // Act
        var result = await _listingService.SearchListingsAsync(
            new ListingFilterParams { SortBy = "mostupvotes" });

        // Assert
        result.Items.Should().BeInDescendingOrder(l => l.UpvoteCount);
    }

    [Fact]
    public async Task SearchListingsAsync_CategoryFilter_ShouldFilter()
    {
        // Arrange
        var owner = await CreateTestOwnerAsync();
        var listing = TestDataFactory.CreateListing(owner.Id, TestConstants.ElectronicsCategoryId);
        _context.Listings.Add(listing);
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing.Id));
        await _context.SaveChangesAsync();

        // Act
        var result = await _listingService.SearchListingsAsync(
            new ListingFilterParams { CategoryId = TestConstants.ElectronicsCategoryId });

        // Assert
        result.Items.Should().NotBeEmpty();
    }
}
