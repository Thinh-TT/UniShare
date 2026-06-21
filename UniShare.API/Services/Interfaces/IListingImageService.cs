using UniShare.API.Models.DTOs.Listings;

namespace UniShare.API.Services.Interfaces;

public interface IListingImageService
{
    Task<List<ListingImageDto>> UploadImagesAsync(Guid listingId, Guid userId, List<IFormFile> files);
    Task<List<ListingImageDto>> SetCoverImageAsync(Guid listingId, Guid imageId, Guid userId);
    Task<List<ListingImageDto>> ReorderImagesAsync(Guid listingId, Guid userId, List<Guid> imageIdsInOrder);
    Task<List<ListingImageDto>> DeleteImageAsync(Guid listingId, Guid imageId, Guid userId);
}
