using UniShare.API.Models;
using UniShare.API.Models.DTOs.RentalRequests;

namespace UniShare.API.Services.Interfaces;

public interface IRentalService
{
    /// <summary>Create a new rental request (Pending) for a listing.</summary>
    Task<RentalRequestDetailDto> CreateRentalRequestAsync(
        Guid listingId, Guid requesterId, CreateRentalRequest request);

    /// <summary>List the current user's rental requests, with optional role and status filters.</summary>
    Task<PagedResponse<RentalRequestSummaryDto>> GetMyRentalRequestsAsync(
        Guid userId, string? role, string? status, int page, int pageSize);

    /// <summary>Get full detail of a rental request. Only requester or owner may view.</summary>
    Task<RentalRequestDetailDto> GetRentalRequestDetailAsync(Guid requestId, Guid userId);

    /// <summary>Owner accepts a Pending request. Auto-rejects other pending requests for the same listing.</summary>
    Task<RentalRequestDetailDto> AcceptRequestAsync(Guid requestId, Guid userId);

    /// <summary>Owner rejects a Pending request.</summary>
    Task<RentalRequestDetailDto> RejectRequestAsync(Guid requestId, Guid userId);

    /// <summary>Requester cancels a Pending or Accepted request.</summary>
    Task<RentalRequestDetailDto> CancelRequestAsync(Guid requestId, Guid userId);

    /// <summary>Start the transaction: Accepted → InProgress. Creates deposit if applicable.</summary>
    Task<RentalRequestDetailDto> StartTransactionAsync(Guid requestId, Guid userId);

    /// <summary>Complete the transaction: InProgress → Completed. Either party can trigger.</summary>
    Task<RentalRequestDetailDto> CompleteTransactionAsync(Guid requestId, Guid userId);
}
