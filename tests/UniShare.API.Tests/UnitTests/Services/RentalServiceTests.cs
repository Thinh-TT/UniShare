using UniShare.API.Tests.Helpers;

namespace UniShare.API.Tests.UnitTests.Services;

public class RentalServiceTests : IDisposable
{
    private readonly AppDbContext _context;
    private readonly IRentalService _rentalService;
    private readonly Mock<INotificationService> _notificationMock;

    public RentalServiceTests()
    {
        var dbName = $"RentalTest_{Guid.NewGuid():N}";
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlite($"DataSource=file:{dbName}?mode=memory&cache=shared")
            .Options;

        _context = new AppDbContext(options);
        _context.Database.OpenConnection();
        _context.Database.EnsureCreated();

        _notificationMock = new Mock<INotificationService>();
        _rentalService = new RentalService(_context, _notificationMock.Object);
    }

    public void Dispose()
    {
        _context.Database.CloseConnection();
        _context.Dispose();
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private async Task<User> CreateUserAsync(string email, string fullName, string? phone = null)
    {
        var user = TestDataFactory.CreateUser(email: email, fullName: fullName, phone: phone);
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    private async Task<(User Owner, User Requester, Listing Listing)> CreateListingWithUsersAsync(
        ListingStatus listingStatus = ListingStatus.Available,
        decimal pricePerDay = 50000m,
        decimal? depositAmount = 100000m)
    {
        var owner = await CreateUserAsync(TestConstants.TestEmail, TestConstants.TestFullName, TestConstants.TestPhone);
        var requester = await CreateUserAsync(TestConstants.SecondEmail, TestConstants.SecondFullName, TestConstants.SecondPhone);

        var listing = TestDataFactory.CreateListing(
            ownerId: owner.Id,
            categoryId: TestConstants.ElectronicsCategoryId,
            status: listingStatus,
            pricePerDay: pricePerDay,
            depositAmount: depositAmount);
        _context.Listings.Add(listing);

        // Add images so that the listing's navigation properties are complete
        _context.ListingImages.Add(TestDataFactory.CreateListingImage(listing.Id));

        await _context.SaveChangesAsync();

        return (owner, requester, listing);
    }

    private async Task<RentalRequest> CreatePendingRequestAsync(
        Guid listingId, Guid requesterId, Guid ownerId,
        decimal? depositAmount = null)
    {
        var request = TestDataFactory.CreateRentalRequest(
            listingId: listingId,
            requesterId: requesterId,
            ownerId: ownerId,
            status: RequestStatus.Pending,
            depositAmount: depositAmount);
        _context.RentalRequests.Add(request);
        await _context.SaveChangesAsync();
        return request;
    }

    // ========================================================================
    // CreateRentalRequestAsync Tests
    // ========================================================================

    [Fact]
    public async Task CreateRentalRequest_ValidRequest_ShouldReturnPending()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var dto = new CreateRentalRequest
        {
            StartDate = DateTime.UtcNow.Date.AddDays(1),
            EndDate = DateTime.UtcNow.Date.AddDays(3),
            Message = "I want to rent this"
        };

        // Act
        var result = await _rentalService.CreateRentalRequestAsync(listing.Id, requester.Id, dto);

        // Assert
        result.Should().NotBeNull();
        result.Status.Should().Be("Pending");
        result.TotalPrice.Should().Be(50000m * 3); // 3 days
        result.Message.Should().Be("I want to rent this");
        result.RequesterId.Should().Be(requester.Id);
        result.OwnerId.Should().Be(owner.Id);
    }

    [Fact]
    public async Task CreateRentalRequest_UnavailableListing_ShouldThrow409()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(ListingStatus.Draft);
        var dto = new CreateRentalRequest
        {
            StartDate = DateTime.UtcNow.Date.AddDays(1),
            EndDate = DateTime.UtcNow.Date.AddDays(3)
        };

        // Act
        var act = () => _rentalService.CreateRentalRequestAsync(listing.Id, requester.Id, dto);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    [Fact]
    public async Task CreateRentalRequest_SelfRequest_ShouldThrow409()
    {
        // Arrange
        var (owner, _, listing) = await CreateListingWithUsersAsync();
        var dto = new CreateRentalRequest
        {
            StartDate = DateTime.UtcNow.Date.AddDays(1),
            EndDate = DateTime.UtcNow.Date.AddDays(3)
        };

        // Act
        var act = () => _rentalService.CreateRentalRequestAsync(listing.Id, owner.Id, dto);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    [Fact]
    public async Task CreateRentalRequest_StartAfterEndDate_ShouldThrow409()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var dto = new CreateRentalRequest
        {
            StartDate = DateTime.UtcNow.Date.AddDays(5),
            EndDate = DateTime.UtcNow.Date.AddDays(1)
        };

        // Act
        var act = () => _rentalService.CreateRentalRequestAsync(listing.Id, requester.Id, dto);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    [Fact]
    public async Task CreateRentalRequest_DuplicateActive_ShouldThrow409()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        var dto = new CreateRentalRequest
        {
            StartDate = DateTime.UtcNow.Date.AddDays(1),
            EndDate = DateTime.UtcNow.Date.AddDays(3)
        };

        // Act
        var act = () => _rentalService.CreateRentalRequestAsync(listing.Id, requester.Id, dto);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    [Fact]
    public async Task CreateRentalRequest_ShouldNotifyOwner()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var dto = new CreateRentalRequest
        {
            StartDate = DateTime.UtcNow.Date.AddDays(1),
            EndDate = DateTime.UtcNow.Date.AddDays(3)
        };

        // Act
        await _rentalService.CreateRentalRequestAsync(listing.Id, requester.Id, dto);

        // Assert
        _notificationMock.Verify(
            n => n.CreateNotificationAsync(
                owner.Id,
                NotificationType.RentalRequest,
                It.IsAny<string>(),
                It.IsAny<string>(),
                It.IsAny<Guid>(),
                "RentalRequest"),
            Times.Once);
    }

    // ========================================================================
    // State Transition: Pending → Accepted
    // ========================================================================

    [Fact]
    public async Task AcceptRequest_ValidPending_ShouldTransitionToAccepted()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        var result = await _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Assert
        result.Status.Should().Be("Accepted");
        await _context.Entry(request).ReloadAsync();
        request.Status.Should().Be(RequestStatus.Accepted);
    }

    [Fact]
    public async Task AcceptRequest_NonOwner_ShouldThrow403()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        var act = () => _rentalService.AcceptRequestAsync(request.Id, requester.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    [Fact]
    public async Task AcceptRequest_ShouldSetListingReserved()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Assert
        await _context.Entry(listing).ReloadAsync();
        listing.Status.Should().Be(ListingStatus.Reserved);
    }

    [Fact]
    public async Task AcceptRequest_ShouldAutoRejectOtherPending()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var requester2 = await CreateUserAsync("third@test.com", "Third User", "0909090909");
        var request1 = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        var request2 = await CreatePendingRequestAsync(listing.Id, requester2.Id, owner.Id);

        // Act
        await _rentalService.AcceptRequestAsync(request1.Id, owner.Id);

        // Assert
        await _context.Entry(request2).ReloadAsync();
        request2.Status.Should().Be(RequestStatus.Rejected);
    }

    // ========================================================================
    // State Transition: Pending → Rejected
    // ========================================================================

    [Fact]
    public async Task RejectRequest_ValidPending_ShouldTransitionToRejected()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        var result = await _rentalService.RejectRequestAsync(request.Id, owner.Id);

        // Assert
        result.Status.Should().Be("Rejected");
    }

    [Fact]
    public async Task RejectRequest_NonOwner_ShouldThrow403()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        var act = () => _rentalService.RejectRequestAsync(request.Id, requester.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    // ========================================================================
    // State Transition: Pending → Cancelled
    // ========================================================================

    [Fact]
    public async Task CancelRequest_ValidPending_ShouldTransitionToCancelled()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        var result = await _rentalService.CancelRequestAsync(request.Id, requester.Id);

        // Assert
        result.Status.Should().Be("Cancelled");
    }

    [Fact]
    public async Task CancelRequest_NonRequester_ShouldThrow403()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);

        // Act
        var act = () => _rentalService.CancelRequestAsync(request.Id, owner.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    // ========================================================================
    // State Transition: Accepted → Cancelled
    // ========================================================================

    [Fact]
    public async Task CancelRequest_FromAccepted_ShouldRevertListingToAvailable()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Act
        await _rentalService.CancelRequestAsync(request.Id, requester.Id);

        // Assert
        await _context.Entry(listing).ReloadAsync();
        listing.Status.Should().Be(ListingStatus.Available);
    }

    // ========================================================================
    // State Transition: Accepted → InProgress
    // ========================================================================

    [Fact]
    public async Task StartTransaction_ValidAccepted_ShouldTransitionToInProgress()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 0);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Act
        var result = await _rentalService.StartTransactionAsync(request.Id, owner.Id);

        // Assert
        result.Status.Should().Be("InProgress");
        await _context.Entry(listing).ReloadAsync();
        listing.Status.Should().Be(ListingStatus.InUse);
    }

    [Fact]
    public async Task StartTransaction_NonOwner_ShouldThrow403()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Act
        var act = () => _rentalService.StartTransactionAsync(request.Id, requester.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    [Fact]
    public async Task StartTransaction_WithDepositAmount_ShouldCreateDeposit()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 200000m);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Act
        await _rentalService.StartTransactionAsync(request.Id, owner.Id);

        // Assert
        var deposit = await _context.Deposits
            .FirstOrDefaultAsync(d => d.RentalRequestId == request.Id);
        deposit.Should().NotBeNull();
        deposit!.Amount.Should().Be(200000m);
        deposit.Status.Should().Be(DepositStatus.Pending);
    }

    // ========================================================================
    // State Transition: InProgress → Completed
    // ========================================================================

    [Fact]
    public async Task CompleteTransaction_ValidInProgress_ShouldTransitionToCompleted()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 0);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);
        await _rentalService.StartTransactionAsync(request.Id, owner.Id);

        // Act - complete by requester
        var result = await _rentalService.CompleteTransactionAsync(request.Id, requester.Id);

        // Assert
        result.Status.Should().Be("Completed");
    }

    [Fact]
    public async Task CompleteTransaction_EitherPartyCanComplete()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 0);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);
        await _rentalService.StartTransactionAsync(request.Id, owner.Id);

        // Act - complete by owner
        var act = () => _rentalService.CompleteTransactionAsync(request.Id, owner.Id);

        // Assert
        await act.Should().NotThrowAsync();
    }

    [Fact]
    public async Task CompleteTransaction_ShouldSetListingBackToAvailable()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 0);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);
        await _rentalService.StartTransactionAsync(request.Id, owner.Id);

        // Act
        await _rentalService.CompleteTransactionAsync(request.Id, requester.Id);

        // Assert
        await _context.Entry(listing).ReloadAsync();
        listing.Status.Should().Be(ListingStatus.Available);
    }

    [Fact]
    public async Task CompleteTransaction_NonParticipant_ShouldThrow403()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 0);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);
        await _rentalService.StartTransactionAsync(request.Id, owner.Id);
        var outsider = await CreateUserAsync("outsider@test.com", "Outsider");

        // Act
        var act = () => _rentalService.CompleteTransactionAsync(request.Id, outsider.Id);

        // Assert
        await act.Should().ThrowAsync<ForbiddenException>();
    }

    // ========================================================================
    // Terminal State Tests
    // ========================================================================

    [Fact]
    public async Task CompletedState_ShouldNotTransitionToAny()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync(depositAmount: 0);
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.AcceptRequestAsync(request.Id, owner.Id);
        await _rentalService.StartTransactionAsync(request.Id, owner.Id);
        await _rentalService.CompleteTransactionAsync(request.Id, requester.Id);

        // Act & Assert
        var accept = () => _rentalService.AcceptRequestAsync(request.Id, owner.Id);
        await accept.Should().ThrowAsync<BusinessRuleViolationException>();

        var start = () => _rentalService.StartTransactionAsync(request.Id, owner.Id);
        await start.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    [Fact]
    public async Task RejectedState_ShouldNotTransitionToAccepted()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.RejectRequestAsync(request.Id, owner.Id);

        // Act
        var act = () => _rentalService.AcceptRequestAsync(request.Id, owner.Id);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }

    [Fact]
    public async Task CancelledState_ShouldNotTransitionToInProgress()
    {
        // Arrange
        var (owner, requester, listing) = await CreateListingWithUsersAsync();
        var request = await CreatePendingRequestAsync(listing.Id, requester.Id, owner.Id);
        await _rentalService.CancelRequestAsync(request.Id, requester.Id);

        // Act
        var act = () => _rentalService.StartTransactionAsync(request.Id, owner.Id);

        // Assert
        await act.Should().ThrowAsync<BusinessRuleViolationException>();
    }
}
