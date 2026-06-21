using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Deposits;
using UniShare.API.Models.DTOs.RentalRequests;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class RentalService : IRentalService
{
    private readonly AppDbContext _context;
    private readonly INotificationService _notificationService;

    public RentalService(AppDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    // ========================================================================
    // State Machine
    // ========================================================================

    private static readonly Dictionary<RequestStatus, HashSet<RequestStatus>> AllowedTransitions = new()
    {
        [RequestStatus.Pending] = new() { RequestStatus.Accepted, RequestStatus.Rejected, RequestStatus.Cancelled },
        [RequestStatus.Accepted] = new() { RequestStatus.Cancelled, RequestStatus.InProgress },
        [RequestStatus.InProgress] = new() { RequestStatus.Completed }
        // Completed, Rejected, Cancelled are terminal — no outgoing transitions
    };

    private static void EnsureValidTransition(RentalRequest request, RequestStatus target)
    {
        if (!AllowedTransitions.TryGetValue(request.Status, out var allowed) || !allowed.Contains(target))
        {
            throw new BusinessRuleViolationException(
                $"Cannot transition from {request.Status} to {target}.");
        }
    }

    // ========================================================================
    // CREATE
    // ========================================================================

    public async Task<RentalRequestDetailDto> CreateRentalRequestAsync(
        Guid listingId, Guid requesterId, CreateRentalRequest request)
    {
        var listing = await _context.Listings
            .Include(l => l.Owner)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found.");

        if (listing.Status != ListingStatus.Available)
            throw new BusinessRuleViolationException("This listing is not available for rent.");

        if (listing.OwnerId == requesterId)
            throw new BusinessRuleViolationException("You cannot request your own listing.");

        if (request.StartDate > request.EndDate)
            throw new BusinessRuleViolationException("Start date must be before end date.");

        // Check for existing active request from this user on this listing
        var existingActive = await _context.RentalRequests
            .AnyAsync(r => r.ListingId == listingId
                        && r.RequesterId == requesterId
                        && (r.Status == RequestStatus.Pending
                         || r.Status == RequestStatus.Accepted
                         || r.Status == RequestStatus.InProgress));

        if (existingActive)
            throw new BusinessRuleViolationException("You already have an active request for this listing.");

        var days = Math.Max(1, (int)(request.EndDate.Date - request.StartDate.Date).TotalDays + 1);
        decimal totalPrice = listing.PricePerDay * days;

        var entity = new RentalRequest
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            RequesterId = requesterId,
            OwnerId = listing.OwnerId,
            Status = RequestStatus.Pending,
            StartDate = request.StartDate.Date,
            EndDate = request.EndDate.Date,
            Message = request.Message?.Trim(),
            TotalPrice = totalPrice,
            DepositAmount = listing.DepositAmount,
            CreatedAt = DateTime.UtcNow
        };

        _context.RentalRequests.Add(entity);
        await _context.SaveChangesAsync();

        // Reload with navigation properties
        await _context.Entry(entity).Reference(r => r.Listing).LoadAsync();
        await _context.Entry(entity).Reference(r => r.Requester).LoadAsync();
        await _context.Entry(entity).Reference(r => r.Owner).LoadAsync();

        // Notify listing owner
        if (listing.OwnerId != requesterId)
        {
            await _notificationService.CreateNotificationAsync(
                listing.OwnerId,
                NotificationType.RentalRequest,
                "Yêu cầu thuê mới",
                $"{entity.Requester.FullName} muốn thuê \"{listing.Title}\"",
                entity.Id,
                "RentalRequest");
        }

        return MapToDetailDto(entity);
    }

    // ========================================================================
    // LIST
    // ========================================================================

    public async Task<PagedResponse<RentalRequestSummaryDto>> GetMyRentalRequestsAsync(
        Guid userId, string? role, string? status, int page, int pageSize)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        IQueryable<RentalRequest> query = _context.RentalRequests
            .Include(r => r.Listing)
            .ThenInclude(l => l.Images)
            .Include(r => r.Requester)
            .Include(r => r.Owner);

        // Filter by role
        if (string.Equals(role, "requester", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(r => r.RequesterId == userId);
        }
        else if (string.Equals(role, "owner", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(r => r.OwnerId == userId);
        }
        else
        {
            // Both roles
            query = query.Where(r => r.RequesterId == userId || r.OwnerId == userId);
        }

        // Filter by status
        if (!string.IsNullOrWhiteSpace(status)
            && Enum.TryParse<RequestStatus>(status, ignoreCase: true, out var statusEnum))
        {
            query = query.Where(r => r.Status == statusEnum);
        }

        var totalItems = await query.CountAsync();

        var items = await query
            .OrderByDescending(r => r.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var result = items.Select(r => MapToSummaryDto(r, userId)).ToList();

        return new PagedResponse<RentalRequestSummaryDto>
        {
            Items = result,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalItems
        };
    }

    // ========================================================================
    // DETAIL
    // ========================================================================

    public async Task<RentalRequestDetailDto> GetRentalRequestDetailAsync(Guid requestId, Guid userId)
    {
        var request = await LoadFullRentalRequestAsync(requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.RequesterId != userId && request.OwnerId != userId)
            throw new ForbiddenException("You can only view your own rental requests.");

        return MapToDetailDto(request);
    }

    // ========================================================================
    // ACCEPT (owner only)
    // ========================================================================

    public async Task<RentalRequestDetailDto> AcceptRequestAsync(Guid requestId, Guid userId)
    {
        var request = await LoadFullRentalRequestAsync(requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.OwnerId != userId)
            throw new ForbiddenException("Only the listing owner can accept a request.");

        EnsureValidTransition(request, RequestStatus.Accepted);

        request.Status = RequestStatus.Accepted;
        request.UpdatedAt = DateTime.UtcNow;
        request.Listing.Status = ListingStatus.Reserved;

        // Auto-reject other pending requests for the same listing
        var otherPending = await _context.RentalRequests
            .Where(r => r.ListingId == request.ListingId
                     && r.Id != request.Id
                     && r.Status == RequestStatus.Pending)
            .ToListAsync();

        foreach (var other in otherPending)
        {
            other.Status = RequestStatus.Rejected;
            other.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();

        // Notify accepted requester
        if (request.RequesterId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                request.RequesterId,
                NotificationType.RequestStatus,
                "Yêu cầu được chấp nhận",
                $"Yêu cầu thuê \"{request.Listing.Title}\" của bạn đã được chấp nhận.",
                request.Id,
                "RentalRequest");
        }

        // Notify each auto-rejected requester
        foreach (var other in otherPending)
        {
            if (other.RequesterId != userId)
            {
                await _notificationService.CreateNotificationAsync(
                    other.RequesterId,
                    NotificationType.RequestStatus,
                    "Tin không còn khả dụng",
                    $"Tin \"{request.Listing.Title}\" đã có người thuê.",
                    request.ListingId,
                    "Listing");
            }
        }

        return MapToDetailDto(request);
    }

    // ========================================================================
    // REJECT (owner only)
    // ========================================================================

    public async Task<RentalRequestDetailDto> RejectRequestAsync(Guid requestId, Guid userId)
    {
        var request = await LoadFullRentalRequestAsync(requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.OwnerId != userId)
            throw new ForbiddenException("Only the listing owner can reject a request.");

        EnsureValidTransition(request, RequestStatus.Rejected);

        request.Status = RequestStatus.Rejected;
        request.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        if (request.RequesterId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                request.RequesterId,
                NotificationType.RequestStatus,
                "Yêu cầu bị từ chối",
                $"Yêu cầu thuê \"{request.Listing.Title}\" của bạn đã bị từ chối.",
                request.Id,
                "RentalRequest");
        }

        return MapToDetailDto(request);
    }

    // ========================================================================
    // CANCEL (requester only)
    // ========================================================================

    public async Task<RentalRequestDetailDto> CancelRequestAsync(Guid requestId, Guid userId)
    {
        var request = await _context.RentalRequests
            .Include(r => r.Listing)
            .Include(r => r.Requester)
            .Include(r => r.Owner)
            .Include(r => r.Deposit)
            .FirstOrDefaultAsync(r => r.Id == requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.RequesterId != userId)
            throw new ForbiddenException("Only the requester can cancel a request.");

        EnsureValidTransition(request, RequestStatus.Cancelled);

        var previousStatus = request.Status;

        request.Status = RequestStatus.Cancelled;
        request.UpdatedAt = DateTime.UtcNow;

        // If the request was already accepted, revert the listing status
        if (previousStatus == RequestStatus.Accepted)
        {
            request.Listing.Status = ListingStatus.Available;
        }

        // Cancel any pending/initial deposit
        if (request.Deposit is not null
            && request.Deposit.Status is DepositStatus.None or DepositStatus.Pending)
        {
            request.Deposit.Status = DepositStatus.Cancelled;
            request.Deposit.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();

        if (request.OwnerId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                request.OwnerId,
                NotificationType.RequestStatus,
                "Yêu cầu bị hủy",
                $"Yêu cầu thuê \"{request.Listing.Title}\" đã bị hủy bởi người thuê.",
                request.Id,
                "RentalRequest");
        }

        return MapToDetailDto(request);
    }

    // ========================================================================
    // START TRANSACTION (owner only)
    // ========================================================================

    public async Task<RentalRequestDetailDto> StartTransactionAsync(Guid requestId, Guid userId)
    {
        var request = await _context.RentalRequests
            .Include(r => r.Listing)
            .Include(r => r.Requester)
            .Include(r => r.Owner)
            .Include(r => r.Deposit)
            .FirstOrDefaultAsync(r => r.Id == requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.OwnerId != userId)
            throw new ForbiddenException("Only the listing owner can start the transaction.");

        EnsureValidTransition(request, RequestStatus.InProgress);

        request.Status = RequestStatus.InProgress;
        request.UpdatedAt = DateTime.UtcNow;
        request.Listing.Status = ListingStatus.InUse;

        // Create deposit if listing requires one and none exists
        if (request.Listing.DepositAmount > 0 && request.Deposit is null)
        {
            request.Deposit = new Deposit
            {
                Id = Guid.NewGuid(),
                RentalRequestId = request.Id,
                Amount = request.Listing.DepositAmount.Value,
                Status = DepositStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };

            _context.Deposits.Add(request.Deposit);
        }

        await _context.SaveChangesAsync();

        if (request.RequesterId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                request.RequesterId,
                NotificationType.RequestStatus,
                "Giao dịch bắt đầu",
                $"Giao dịch thuê \"{request.Listing.Title}\" đã bắt đầu.",
                request.Id,
                "RentalRequest");
        }

        return MapToDetailDto(request);
    }

    // ========================================================================
    // COMPLETE TRANSACTION (either party)
    // ========================================================================

    public async Task<RentalRequestDetailDto> CompleteTransactionAsync(Guid requestId, Guid userId)
    {
        var request = await _context.RentalRequests
            .Include(r => r.Listing)
            .Include(r => r.Requester)
            .Include(r => r.Owner)
            .Include(r => r.Deposit)
            .FirstOrDefaultAsync(r => r.Id == requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.RequesterId != userId && request.OwnerId != userId)
            throw new ForbiddenException("You are not a participant in this transaction.");

        EnsureValidTransition(request, RequestStatus.Completed);

        request.Status = RequestStatus.Completed;
        request.UpdatedAt = DateTime.UtcNow;
        request.Listing.Status = ListingStatus.Available;

        await _context.SaveChangesAsync();

        // Notify the counterpart (the other participant)
        var counterpartId = request.RequesterId == userId ? request.OwnerId : request.RequesterId;
        if (counterpartId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                counterpartId,
                NotificationType.RequestStatus,
                "Giao dịch hoàn tất",
                $"Giao dịch thuê \"{request.Listing.Title}\" đã hoàn tất.",
                request.Id,
                "RentalRequest");
        }

        return MapToDetailDto(request);
    }

    // ========================================================================
    // Private helpers
    // ========================================================================

    private async Task<RentalRequest?> LoadFullRentalRequestAsync(Guid requestId)
    {
        return await _context.RentalRequests
            .Include(r => r.Listing)
            .ThenInclude(l => l.Images)
            .Include(r => r.Requester)
            .Include(r => r.Owner)
            .Include(r => r.Deposit)
            .FirstOrDefaultAsync(r => r.Id == requestId);
    }

    // ========================================================================
    // Mappers
    // ========================================================================

    private static RentalRequestSummaryDto MapToSummaryDto(RentalRequest r, Guid viewerId)
    {
        var isRequester = r.RequesterId == viewerId;
        var counterpart = isRequester ? r.Owner : r.Requester;
        var role = isRequester ? "requester" : "owner";
        var listingImageUrl = r.Listing.Images
            .FirstOrDefault(i => i.IsCover)?.ImageUrl;

        return new RentalRequestSummaryDto
        {
            Id = r.Id,
            Status = r.Status.ToString(),
            StartDate = r.StartDate,
            EndDate = r.EndDate,
            TotalPrice = r.TotalPrice,
            DepositAmount = r.DepositAmount,
            CreatedAt = r.CreatedAt,
            ListingId = r.ListingId,
            ListingTitle = r.Listing.Title,
            ListingImageUrl = listingImageUrl,
            OtherParticipantId = counterpart.Id,
            OtherParticipantName = counterpart.FullName,
            OtherParticipantAvatarUrl = counterpart.AvatarUrl,
            Role = role
        };
    }

    private static RentalRequestDetailDto MapToDetailDto(RentalRequest r)
    {
        var listingImageUrl = r.Listing.Images
            .FirstOrDefault(i => i.IsCover)?.ImageUrl;

        DepositDto? depositDto = null;
        if (r.Deposit is not null)
        {
            depositDto = new DepositDto
            {
                Id = r.Deposit.Id,
                RentalRequestId = r.Deposit.RentalRequestId,
                Amount = r.Deposit.Amount,
                Status = r.Deposit.Status.ToString(),
                PaymentProvider = r.Deposit.PaymentProvider,
                ProviderTransactionId = r.Deposit.ProviderTransactionId,
                PaidAt = r.Deposit.PaidAt,
                RefundedAt = r.Deposit.RefundedAt,
                CreatedAt = r.Deposit.CreatedAt
            };
        }

        return new RentalRequestDetailDto
        {
            Id = r.Id,
            Status = r.Status.ToString(),
            StartDate = r.StartDate,
            EndDate = r.EndDate,
            Message = r.Message,
            TotalPrice = r.TotalPrice,
            DepositAmount = r.DepositAmount,
            CreatedAt = r.CreatedAt,
            UpdatedAt = r.UpdatedAt,
            ListingId = r.ListingId,
            ListingTitle = r.Listing.Title,
            ListingImageUrl = listingImageUrl,
            ListingPricePerDay = r.Listing.PricePerDay,
            ListingType = r.Listing.ListingType.ToString(),
            RequesterId = r.RequesterId,
            RequesterName = r.Requester.FullName,
            RequesterAvatarUrl = r.Requester.AvatarUrl,
            OwnerId = r.OwnerId,
            OwnerName = r.Owner.FullName,
            OwnerAvatarUrl = r.Owner.AvatarUrl,
            Deposit = depositDto
        };
    }
}
