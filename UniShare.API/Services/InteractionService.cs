using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Interactions;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class InteractionService : IInteractionService
{
    private readonly AppDbContext _context;

    public InteractionService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<UpvoteResponse> UpvoteAsync(Guid listingId, Guid userId)
    {
        var listing = await ValidateListingActiveAsync(listingId);

        var existing = await _context.Upvotes
            .FirstOrDefaultAsync(u => u.ListingId == listingId && u.UserId == userId);

        if (existing is not null)
        {
            // Idempotent — already upvoted
            return new UpvoteResponse
            {
                ListingId = listingId,
                IsUpvoted = true,
                UpvoteCount = listing.UpvoteCount
            };
        }

        var upvote = new Upvote
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            UserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        _context.Upvotes.Add(upvote);
        listing.UpvoteCount++;

        // Notify listing owner if the upvoter is not the owner
        if (listing.OwnerId != userId)
        {
            _context.Notifications.Add(new Notification
            {
                Id = Guid.NewGuid(),
                UserId = listing.OwnerId,
                Type = NotificationType.Upvote,
                Title = "New upvote",
                Body = $"Someone upvoted your listing \"{listing.Title}\"",
                ReferenceId = listingId,
                ReferenceType = "Listing",
                CreatedAt = DateTime.UtcNow
            });
        }

        await _context.SaveChangesAsync();

        return new UpvoteResponse
        {
            ListingId = listingId,
            IsUpvoted = true,
            UpvoteCount = listing.UpvoteCount
        };
    }

    public async Task<UpvoteResponse> RemoveUpvoteAsync(Guid listingId, Guid userId)
    {
        var listing = await ValidateListingActiveAsync(listingId);

        var existing = await _context.Upvotes
            .FirstOrDefaultAsync(u => u.ListingId == listingId && u.UserId == userId);

        if (existing is null)
        {
            // Idempotent — not upvoted
            return new UpvoteResponse
            {
                ListingId = listingId,
                IsUpvoted = false,
                UpvoteCount = listing.UpvoteCount
            };
        }

        _context.Upvotes.Remove(existing);
        listing.UpvoteCount = Math.Max(0, listing.UpvoteCount - 1);

        await _context.SaveChangesAsync();

        return new UpvoteResponse
        {
            ListingId = listingId,
            IsUpvoted = false,
            UpvoteCount = listing.UpvoteCount
        };
    }

    public async Task<PagedResponse<CommentDto>> GetCommentsAsync(Guid listingId, int page, int pageSize)
    {
        // Verify listing exists (any status, including non-active, so viewers can see
        // comments on reserved/in-use/closed listings)
        var listingExists = await _context.Listings.AnyAsync(l => l.Id == listingId);
        if (!listingExists)
            throw new NotFoundException("Listing not found");

        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var totalCount = await _context.Comments
            .Where(c => c.ListingId == listingId)
            .CountAsync();

        var comments = await _context.Comments
            .Include(c => c.User)
            .Where(c => c.ListingId == listingId)
            .OrderByDescending(c => c.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(c => new CommentDto
            {
                Id = c.Id,
                ListingId = c.ListingId,
                UserId = c.UserId,
                UserName = c.User.FullName,
                UserAvatarUrl = c.User.AvatarUrl,
                ParentCommentId = c.ParentCommentId,
                Content = c.Content,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            })
            .ToListAsync();

        return new PagedResponse<CommentDto>
        {
            Items = comments,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        };
    }

    public async Task<CommentDto> CreateCommentAsync(Guid listingId, Guid userId, CreateCommentRequest request)
    {
        var listing = await ValidateListingActiveAsync(listingId);

        // If replying to a parent comment, verify it belongs to the same listing
        if (request.ParentCommentId.HasValue)
        {
            var parent = await _context.Comments
                .FirstOrDefaultAsync(c => c.Id == request.ParentCommentId.Value);

            if (parent is null)
                throw new NotFoundException("Parent comment not found");

            if (parent.ListingId != listingId)
                throw new BusinessRuleViolationException(
                    "Parent comment does not belong to this listing");
        }

        var comment = new Comment
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            UserId = userId,
            ParentCommentId = request.ParentCommentId,
            Content = request.Content.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        _context.Comments.Add(comment);
        listing.CommentCount++;

        // Notify listing owner if the commenter is not the owner
        if (listing.OwnerId != userId)
        {
            _context.Notifications.Add(new Notification
            {
                Id = Guid.NewGuid(),
                UserId = listing.OwnerId,
                Type = NotificationType.Comment,
                Title = "New comment",
                Body = $"Someone commented on your listing \"{listing.Title}\"",
                ReferenceId = listingId,
                ReferenceType = "Listing",
                CreatedAt = DateTime.UtcNow
            });
        }

        await _context.SaveChangesAsync();

        // Load user for the response DTO
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        return MapToCommentDto(comment, user);
    }

    public async Task<CommentDto> UpdateCommentAsync(Guid commentId, Guid userId, UpdateCommentRequest request)
    {
        var comment = await _context.Comments
            .Include(c => c.User)
            .FirstOrDefaultAsync(c => c.Id == commentId);

        if (comment is null)
            throw new NotFoundException("Comment not found");

        if (comment.UserId != userId)
            throw new ForbiddenException("You can only update your own comments");

        comment.Content = request.Content.Trim();
        comment.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return MapToCommentDto(comment, comment.User);
    }

    public async Task SoftDeleteCommentAsync(Guid commentId, Guid userId, bool isAdmin)
    {
        var comment = await _context.Comments
            .Include(c => c.Listing)
            .FirstOrDefaultAsync(c => c.Id == commentId);

        if (comment is null)
            throw new NotFoundException("Comment not found");

        if (comment.UserId != userId && !isAdmin)
            throw new ForbiddenException("You can only delete your own comments");

        comment.DeletedAt = DateTime.UtcNow;
        comment.UpdatedAt = DateTime.UtcNow;
        comment.Listing.CommentCount = Math.Max(0, comment.Listing.CommentCount - 1);

        await _context.SaveChangesAsync();
    }

    // --- Private helpers ---

    /// <summary>
    /// Validates that the listing exists and is in an interactable state.
    /// Returns the listing entity for reuse.
    /// </summary>
    private async Task<Listing> ValidateListingActiveAsync(Guid listingId)
    {
        var listing = await _context.Listings
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.Status is ListingStatus.Draft
            or ListingStatus.Closed
            or ListingStatus.Hidden)
        {
            throw new BusinessRuleViolationException(
                $"Cannot interact with a listing that is {listing.Status.ToString().ToLower()}");
        }

        return listing;
    }

    private static CommentDto MapToCommentDto(Comment comment, User? user) => new()
    {
        Id = comment.Id,
        ListingId = comment.ListingId,
        UserId = comment.UserId,
        UserName = user?.FullName ?? "Unknown",
        UserAvatarUrl = user?.AvatarUrl,
        ParentCommentId = comment.ParentCommentId,
        Content = comment.Content,
        CreatedAt = comment.CreatedAt,
        UpdatedAt = comment.UpdatedAt
    };
}
