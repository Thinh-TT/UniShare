using UniShare.API.Models;
using UniShare.API.Models.DTOs.Listings;

namespace UniShare.API.Services.Interfaces;

public interface IListingService
{
    Task<PagedResponse<ListingSummaryDto>> SearchListingsAsync(ListingFilterParams filters);
    Task<ListingDetailDto> GetListingDetailAsync(Guid listingId);
    Task<ListingDetailDto> CreateListingAsync(Guid ownerId, CreateListingRequest request);
    Task<ListingDetailDto> UpdateListingAsync(Guid listingId, Guid userId, UpdateListingRequest request);
    Task CloseListingAsync(Guid listingId, Guid userId);
    Task SoftDeleteListingAsync(Guid listingId, Guid userId);
    Task<PagedResponse<ListingSummaryDto>> GetMyListingsAsync(Guid userId, int page = 1, int pageSize = 20);
}
