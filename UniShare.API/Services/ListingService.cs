using System.Globalization;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Listings;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;
using TagDto = UniShare.API.Models.DTOs.Metadata.TagDto;

namespace UniShare.API.Services;

public class ListingService : IListingService
{
    private readonly AppDbContext _context;

    public ListingService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<PagedResponse<ListingSummaryDto>> SearchListingsAsync(ListingFilterParams filters)
    {
        var query = _context.Listings
            .Include(l => l.Images)
            .Include(l => l.Owner)
            .Include(l => l.School)
            .Include(l => l.Area)
            .Where(l => l.Status == ListingStatus.Available);

        // Keyword search on title and description
        if (!string.IsNullOrWhiteSpace(filters.Keyword))
        {
            var keyword = filters.Keyword.Trim().ToLower();
            query = query.Where(l =>
                l.Title.ToLower().Contains(keyword) ||
                l.Description.ToLower().Contains(keyword));
        }

        // Filter by category
        if (filters.CategoryId.HasValue)
        {
            query = query.Where(l => l.CategoryId == filters.CategoryId.Value);
        }

        // Filter by tag
        if (filters.TagId.HasValue)
        {
            query = query.Where(l =>
                l.ListingTags.Any(lt => lt.TagId == filters.TagId.Value));
        }

        // Filter by school
        if (filters.SchoolId.HasValue)
        {
            query = query.Where(l => l.SchoolId == filters.SchoolId.Value);
        }

        // Filter by area
        if (filters.AreaId.HasValue)
        {
            query = query.Where(l => l.AreaId == filters.AreaId.Value);
        }

        // Filter by listing type
        if (!string.IsNullOrWhiteSpace(filters.ListingType))
        {
            if (Enum.TryParse<ListingType>(filters.ListingType, ignoreCase: true, out var listingType))
            {
                query = query.Where(l => l.ListingType == listingType);
            }
        }

        // Filter by price range
        if (filters.MinPrice.HasValue)
        {
            query = query.Where(l => l.PricePerDay >= filters.MinPrice.Value);
        }
        if (filters.MaxPrice.HasValue)
        {
            query = query.Where(l => l.PricePerDay <= filters.MaxPrice.Value);
        }

        // Count before pagination
        var totalCount = await query.CountAsync();

        // Sorting
        query = (filters.SortBy?.ToLower()) switch
        {
            "priceasc" => query.OrderBy(l => l.PricePerDay),
            "pricedesc" => query.OrderByDescending(l => l.PricePerDay),
            "mostupvotes" => query.OrderByDescending(l => l.UpvoteCount),
            _ => query.OrderByDescending(l => l.CreatedAt) // "newest" default
        };

        // Pagination
        var page = Math.Max(1, filters.Page);
        var pageSize = Math.Clamp(filters.PageSize, 1, 50);

        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(l => new ListingSummaryDto
            {
                Id = l.Id,
                Title = l.Title,
                PricePerDay = l.PricePerDay,
                DepositAmount = l.DepositAmount,
                ListingType = l.ListingType.ToString(),
                Status = l.Status.ToString(),
                CoverImageUrl = l.Images
                    .Where(i => i.IsCover)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                SchoolName = l.School != null ? l.School.Name : null,
                AreaName = l.Area != null ? l.Area.Name : null,
                OwnerName = l.Owner.FullName,
                OwnerAvatarUrl = l.Owner.AvatarUrl,
                UpvoteCount = l.UpvoteCount,
                CommentCount = l.CommentCount,
                CreatedAt = l.CreatedAt
            })
            .ToListAsync();

        return new PagedResponse<ListingSummaryDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        };
    }

    public async Task<ListingDetailDto> GetListingDetailAsync(Guid listingId)
    {
        var listing = await _context.Listings
            .Include(l => l.Category)
            .Include(l => l.School)
            .Include(l => l.Area)
            .Include(l => l.Images.OrderBy(i => i.DisplayOrder))
            .Include(l => l.ListingTags)
                .ThenInclude(lt => lt.Tag)
            .Include(l => l.Owner)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        // Increment view count
        listing.ViewCount++;
        await _context.SaveChangesAsync();

        return MapToDetail(listing);
    }

    public async Task<ListingDetailDto> CreateListingAsync(Guid ownerId, CreateListingRequest request)
    {
        // Validate owner exists
        var owner = await _context.Users.FirstOrDefaultAsync(u => u.Id == ownerId && u.IsActive);
        if (owner is null)
            throw new NotFoundException("User not found or inactive");

        // Validate category exists and is active
        var category = await _context.Categories
            .FirstOrDefaultAsync(c => c.Id == request.CategoryId && c.IsActive);
        if (category is null)
            throw new NotFoundException("Category not found or inactive");

        // Validate school if provided
        if (request.SchoolId.HasValue)
        {
            var school = await _context.Schools
                .FirstOrDefaultAsync(s => s.Id == request.SchoolId.Value && s.IsActive);
            if (school is null)
                throw new NotFoundException("School not found or inactive");
        }

        // Validate area if provided
        if (request.AreaId.HasValue)
        {
            var area = await _context.Areas
                .FirstOrDefaultAsync(a => a.Id == request.AreaId.Value && a.IsActive);
            if (area is null)
                throw new NotFoundException("Area not found or inactive");
        }

        // Parse listing type
        if (!Enum.TryParse<ListingType>(request.ListingType, ignoreCase: true, out var listingType))
            throw new BusinessRuleViolationException("Invalid listing type. Must be 'Rent' or 'Borrow'");

        // Normalize tags (find or create)
        var tags = await NormalizeTagsAsync(request.TagNames ?? new List<string>());

        var listing = new Listing
        {
            Id = Guid.NewGuid(),
            OwnerId = ownerId,
            CategoryId = request.CategoryId,
            SchoolId = request.SchoolId,
            AreaId = request.AreaId,
            Title = request.Title.Trim(),
            Description = request.Description.Trim(),
            ListingType = listingType,
            Status = ListingStatus.Available,
            PricePerDay = listingType == ListingType.Borrow ? 0 : request.PricePerDay,
            DepositAmount = request.DepositAmount,
            ConditionNote = request.ConditionNote?.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        _context.Listings.Add(listing);

        // Create ListingTags
        foreach (var tag in tags)
        {
            _context.Set<ListingTag>().Add(new ListingTag
            {
                ListingId = listing.Id,
                TagId = tag.Id
            });
        }

        await _context.SaveChangesAsync();

        // Set category and owner for the response
        listing.Category = category;
        listing.Owner = owner;
        listing.School = request.SchoolId.HasValue
            ? await _context.Schools.FirstOrDefaultAsync(s => s.Id == request.SchoolId.Value)
            : null;
        listing.Area = request.AreaId.HasValue
            ? await _context.Areas.FirstOrDefaultAsync(a => a.Id == request.AreaId.Value)
            : null;

        // Build tag list for response
        foreach (var tag in tags)
        {
            listing.ListingTags.Add(new ListingTag { ListingId = listing.Id, TagId = tag.Id, Tag = tag });
        }

        return MapToDetail(listing);
    }

    public async Task<ListingDetailDto> UpdateListingAsync(Guid listingId, Guid userId, UpdateListingRequest request)
    {
        var listing = await _context.Listings
            .Include(l => l.Category)
            .Include(l => l.School)
            .Include(l => l.Area)
            .Include(l => l.Images.OrderBy(i => i.DisplayOrder))
            .Include(l => l.ListingTags)
                .ThenInclude(lt => lt.Tag)
            .Include(l => l.Owner)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only update your own listings");

        // Update scalar fields if provided
        if (request.Title is not null)
            listing.Title = request.Title.Trim();

        if (request.Description is not null)
            listing.Description = request.Description.Trim();

        if (request.CategoryId.HasValue)
        {
            var category = await _context.Categories
                .FirstOrDefaultAsync(c => c.Id == request.CategoryId.Value && c.IsActive);
            if (category is null)
                throw new NotFoundException("Category not found or inactive");
            listing.CategoryId = request.CategoryId.Value;
            listing.Category = category;
        }

        if (request.SchoolId.HasValue)
        {
            var school = await _context.Schools
                .FirstOrDefaultAsync(s => s.Id == request.SchoolId.Value && s.IsActive);
            if (school is null)
                throw new NotFoundException("School not found or inactive");
            listing.SchoolId = request.SchoolId.Value;
            listing.School = school;
        }

        if (request.AreaId.HasValue)
        {
            var area = await _context.Areas
                .FirstOrDefaultAsync(a => a.Id == request.AreaId.Value && a.IsActive);
            if (area is null)
                throw new NotFoundException("Area not found or inactive");
            listing.AreaId = request.AreaId.Value;
            listing.Area = area;
        }

        if (request.PricePerDay.HasValue)
        {
            if (listing.ListingType == ListingType.Borrow && request.PricePerDay.Value != 0)
                throw new BusinessRuleViolationException("Price per day must be 0 for Borrow listings");
            listing.PricePerDay = request.PricePerDay.Value;
        }

        if (request.DepositAmount.HasValue)
        {
            listing.DepositAmount = request.DepositAmount.Value;
        }

        if (request.ConditionNote is not null)
            listing.ConditionNote = string.IsNullOrWhiteSpace(request.ConditionNote)
                ? null
                : request.ConditionNote.Trim();

        // Re-sync tags if provided
        if (request.TagNames is not null)
        {
            // Remove existing ListingTags
            var existingTags = await _context.Set<ListingTag>()
                .Where(lt => lt.ListingId == listingId)
                .ToListAsync();
            _context.Set<ListingTag>().RemoveRange(existingTags);

            // Normalize and create new tags
            var normalizedTags = await NormalizeTagsAsync(request.TagNames);

            listing.ListingTags.Clear();
            foreach (var tag in normalizedTags)
            {
                listing.ListingTags.Add(new ListingTag
                {
                    ListingId = listing.Id,
                    TagId = tag.Id,
                    Tag = tag
                });
            }
        }

        listing.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return MapToDetail(listing);
    }

    public async Task CloseListingAsync(Guid listingId, Guid userId)
    {
        var listing = await _context.Listings
            .Include(l => l.RentalRequests)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only close your own listings");

        // Check for active rental (InProgress)
        if (listing.RentalRequests.Any(r => r.Status == RequestStatus.InProgress))
            throw new BusinessRuleViolationException(
                "Cannot close a listing with an active transaction in progress");

        listing.Status = ListingStatus.Closed;
        listing.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    public async Task SoftDeleteListingAsync(Guid listingId, Guid userId)
    {
        var listing = await _context.Listings
            .Include(l => l.RentalRequests)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.OwnerId != userId)
            throw new ForbiddenException("You can only delete your own listings");

        // Check for active rental
        if (listing.RentalRequests.Any(r => r.Status == RequestStatus.InProgress))
            throw new BusinessRuleViolationException(
                "Cannot delete a listing with an active transaction in progress");

        listing.DeletedAt = DateTime.UtcNow;
        listing.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    public async Task<PagedResponse<ListingSummaryDto>> GetMyListingsAsync(
        Guid userId, int page = 1, int pageSize = 20)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var query = _context.Listings
            .Include(l => l.Images)
            .Include(l => l.Owner)
            .Include(l => l.School)
            .Include(l => l.Area)
            .Where(l => l.OwnerId == userId);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(l => l.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(l => new ListingSummaryDto
            {
                Id = l.Id,
                Title = l.Title,
                PricePerDay = l.PricePerDay,
                DepositAmount = l.DepositAmount,
                ListingType = l.ListingType.ToString(),
                Status = l.Status.ToString(),
                CoverImageUrl = l.Images
                    .Where(i => i.IsCover)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                SchoolName = l.School != null ? l.School.Name : null,
                AreaName = l.Area != null ? l.Area.Name : null,
                OwnerName = l.Owner.FullName,
                OwnerAvatarUrl = l.Owner.AvatarUrl,
                UpvoteCount = l.UpvoteCount,
                CommentCount = l.CommentCount,
                CreatedAt = l.CreatedAt
            })
            .ToListAsync();

        return new PagedResponse<ListingSummaryDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        };
    }

    // --- Private helpers ---

    private static ListingDetailDto MapToDetail(Listing listing) => new()
    {
        Id = listing.Id,
        Title = listing.Title,
        Description = listing.Description,
        PricePerDay = listing.PricePerDay,
        DepositAmount = listing.DepositAmount,
        ConditionNote = listing.ConditionNote,
        ListingType = listing.ListingType.ToString(),
        Status = listing.Status.ToString(),
        CategoryName = listing.Category?.Name ?? "Unknown",
        SchoolName = listing.School?.Name,
        AreaName = listing.Area?.Name,
        ViewCount = listing.ViewCount,
        UpvoteCount = listing.UpvoteCount,
        CommentCount = listing.CommentCount,
        OwnerId = listing.OwnerId,
        OwnerName = listing.Owner?.FullName ?? "Unknown",
        OwnerAvatarUrl = listing.Owner?.AvatarUrl,
        OwnerReputationScore = (int)(listing.Owner?.ReputationScore ?? 100),
        Images = listing.Images
            .OrderBy(i => i.DisplayOrder)
            .Select(i => new ListingImageDto
            {
                Id = i.Id,
                ImageUrl = i.ImageUrl,
                DisplayOrder = i.DisplayOrder,
                IsCover = i.IsCover
            })
            .ToList(),
        Tags = listing.ListingTags
            .Select(lt => new TagDto
            {
                Id = lt.Tag.Id,
                Name = lt.Tag.Name,
                Slug = lt.Tag.Slug
            })
            .ToList(),
        CreatedAt = listing.CreatedAt,
        UpdatedAt = listing.UpdatedAt
    };

    private async Task<List<Tag>> NormalizeTagsAsync(List<string> tagNames)
    {
        if (tagNames.Count == 0)
            return new List<Tag>();

        // Slugify and deduplicate
        var slugs = tagNames
            .Select(Slugify)
            .Where(s => !string.IsNullOrWhiteSpace(s))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (slugs.Count == 0)
            return new List<Tag>();

        // Find existing tags
        var existing = await _context.Tags
            .Where(t => slugs.Contains(t.Slug))
            .ToListAsync();

        // Create new tags for slugs that don't exist yet
        var existingSlugs = existing.Select(t => t.Slug.ToLower()).ToHashSet();
        var newSlugs = slugs.Where(s => !existingSlugs.Contains(s.ToLower())).ToList();

        var newTags = newSlugs.Select(s => new Tag
        {
            Id = Guid.NewGuid(),
            Name = s, // Use slug as display name for user-created tags
            Slug = s,
            CreatedAt = DateTime.UtcNow
        }).ToList();

        if (newTags.Count > 0)
            _context.Tags.AddRange(newTags);

        return existing.Concat(newTags).ToList();
    }

    private static string Slugify(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return string.Empty;

        // Normalize and lowercase
        var normalized = input.Trim().ToLowerInvariant();

        // Remove diacritics (accents)
        normalized = RemoveDiacritics(normalized);

        // Replace non-alphanumeric characters with hyphens
        normalized = Regex.Replace(normalized, @"[^a-z0-9\s-]", "");
        normalized = Regex.Replace(normalized, @"[\s-]+", "-");
        normalized = normalized.Trim('-');

        return normalized;
    }

    private static string RemoveDiacritics(string text)
    {
        var normalizedString = text.Normalize(System.Text.NormalizationForm.FormD);
        var stringBuilder = new System.Text.StringBuilder();

        foreach (var c in normalizedString)
        {
            var unicodeCategory = CharUnicodeInfo.GetUnicodeCategory(c);
            if (unicodeCategory != UnicodeCategory.NonSpacingMark)
            {
                stringBuilder.Append(c);
            }
        }

        return stringBuilder.ToString().Normalize(System.Text.NormalizationForm.FormC);
    }
}
