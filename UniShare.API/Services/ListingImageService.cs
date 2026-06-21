using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models.DTOs.Listings;
using UniShare.API.Models.Entities;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class ListingImageService : IListingImageService
{
    private readonly AppDbContext _context;
    private readonly IWebHostEnvironment _env;

    private static readonly HashSet<string> AllowedExtensions = new(
        StringComparer.OrdinalIgnoreCase) { ".jpg", ".jpeg", ".png", ".webp" };

    private const long MaxFileSize = 5 * 1024 * 1024; // 5 MB
    private const int MaxImagesPerListing = 10;
    private const string UploadSubfolder = "uploads/listings";

    public ListingImageService(AppDbContext context, IWebHostEnvironment env)
    {
        _context = context;
        _env = env;
    }

    public async Task<List<ListingImageDto>> UploadImagesAsync(
        Guid listingId, Guid userId, List<IFormFile> files)
    {
        var listing = await _context.Listings
            .Include(l => l.Images)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only upload images to your own listings");

        if (files.Count == 0)
            throw new BusinessRuleViolationException("At least one file is required");

        // Check total image count after upload
        if (listing.Images.Count + files.Count > MaxImagesPerListing)
            throw new BusinessRuleViolationException(
                $"Maximum {MaxImagesPerListing} images per listing. " +
                $"Current: {listing.Images.Count}, attempting to add: {files.Count}");

        // Validate each file
        foreach (var file in files)
        {
            var ext = Path.GetExtension(file.FileName);
            if (!AllowedExtensions.Contains(ext))
                throw new BusinessRuleViolationException(
                    $"File type '{ext}' is not allowed. Allowed: {string.Join(", ", AllowedExtensions)}");

            if (file.Length > MaxFileSize)
                throw new BusinessRuleViolationException(
                    $"File '{file.FileName}' exceeds the maximum size of 5 MB");

            if (file.Length == 0)
                throw new BusinessRuleViolationException($"File '{file.FileName}' is empty");
        }

        // Determine upload directory
        var uploadDir = GetUploadDirectory(listingId);
        Directory.CreateDirectory(uploadDir);

        var isFirstImage = listing.Images.Count == 0;
        var nextOrder = listing.Images.Count > 0
            ? listing.Images.Max(i => i.DisplayOrder) + 1
            : 1;

        foreach (var file in files)
        {
            var ext = Path.GetExtension(file.FileName);
            var fileName = $"{Guid.NewGuid()}{ext}";
            var filePath = Path.Combine(uploadDir, fileName);

            // Save file to disk
            await using var stream = new FileStream(filePath, FileMode.Create);
            await file.CopyToAsync(stream);

            // Create image entity
            var image = new ListingImage
            {
                Id = Guid.NewGuid(),
                ListingId = listingId,
                ImageUrl = $"/{UploadSubfolder}/{listingId}/{fileName}",
                DisplayOrder = nextOrder++,
                IsCover = isFirstImage && file == files[0], // First image of first upload = cover
                CreatedAt = DateTime.UtcNow
            };

            _context.Set<ListingImage>().Add(image);
            listing.Images.Add(image);

            isFirstImage = false;
        }

        await _context.SaveChangesAsync();

        return MapToDtoList(listing.Images);
    }

    public async Task<List<ListingImageDto>> SetCoverImageAsync(
        Guid listingId, Guid imageId, Guid userId)
    {
        var listing = await _context.Listings
            .Include(l => l.Images)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only manage images of your own listings");

        var targetImage = listing.Images.FirstOrDefault(i => i.Id == imageId);
        if (targetImage is null)
            throw new NotFoundException("Image not found for this listing");

        // Unset current cover, set new cover
        foreach (var img in listing.Images)
        {
            img.IsCover = img.Id == imageId;
        }

        await _context.SaveChangesAsync();

        return MapToDtoList(listing.Images);
    }

    public async Task<List<ListingImageDto>> ReorderImagesAsync(
        Guid listingId, Guid userId, List<Guid> imageIdsInOrder)
    {
        var listing = await _context.Listings
            .Include(l => l.Images)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only manage images of your own listings");

        if (imageIdsInOrder.Count != listing.Images.Count)
            throw new BusinessRuleViolationException(
                "The number of image IDs must match the total number of images");

        var existingImageIds = listing.Images.Select(i => i.Id).ToHashSet();
        if (imageIdsInOrder.Any(id => !existingImageIds.Contains(id)))
            throw new BusinessRuleViolationException(
                "One or more image IDs do not belong to this listing");

        // Update display order
        for (int i = 0; i < imageIdsInOrder.Count; i++)
        {
            var image = listing.Images.First(img => img.Id == imageIdsInOrder[i]);
            image.DisplayOrder = i + 1;
        }

        await _context.SaveChangesAsync();

        return MapToDtoList(listing.Images);
    }

    public async Task<List<ListingImageDto>> DeleteImageAsync(
        Guid listingId, Guid imageId, Guid userId)
    {
        var listing = await _context.Listings
            .Include(l => l.Images)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only manage images of your own listings");

        if (listing.Images.Count <= 1)
            throw new BusinessRuleViolationException(
                "Cannot delete the last image of a listing");

        var image = listing.Images.FirstOrDefault(i => i.Id == imageId);
        if (image is null)
            throw new NotFoundException("Image not found for this listing");

        var wasCover = image.IsCover;

        // Delete file from disk
        var filePath = GetFilePathFromUrl(image.ImageUrl);
        if (File.Exists(filePath))
        {
            File.Delete(filePath);
        }

        // Remove from database
        _context.Set<ListingImage>().Remove(image);
        listing.Images.Remove(image);

        // If we deleted the cover, set the first remaining image as cover
        if (wasCover && listing.Images.Count > 0)
        {
            var newCover = listing.Images.OrderBy(i => i.DisplayOrder).First();
            newCover.IsCover = true;
        }

        await _context.SaveChangesAsync();

        return MapToDtoList(listing.Images);
    }

    // --- Private helpers ---

    private string GetUploadDirectory(Guid listingId)
    {
        return Path.Combine(_env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot"),
            UploadSubfolder, listingId.ToString());
    }

    private string GetFilePathFromUrl(string imageUrl)
    {
        // imageUrl format: "/uploads/listings/{listingId}/{filename}"
        var relativePath = imageUrl.TrimStart('/');
        return Path.Combine(
            _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot"),
            relativePath);
    }

    private static List<ListingImageDto> MapToDtoList(ICollection<ListingImage> images)
    {
        return images
            .OrderBy(i => i.DisplayOrder)
            .Select(i => new ListingImageDto
            {
                Id = i.Id,
                ImageUrl = i.ImageUrl,
                DisplayOrder = i.DisplayOrder,
                IsCover = i.IsCover
            })
            .ToList();
    }
}
