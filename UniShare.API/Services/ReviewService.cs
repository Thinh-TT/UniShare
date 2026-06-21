using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models.DTOs.Reviews;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class ReviewService : IReviewService
{
    private readonly AppDbContext _context;
    private readonly INotificationService _notificationService;

    public ReviewService(AppDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task<ReviewDto> CreateReviewAsync(
        Guid rentalRequestId, Guid reviewerId, CreateReviewRequest request)
    {
        var rentalRequest = await _context.RentalRequests
            .Include(r => r.Reviews)
            .Include(r => r.Requester)
            .Include(r => r.Owner)
            .FirstOrDefaultAsync(r => r.Id == rentalRequestId);

        if (rentalRequest is null)
            throw new NotFoundException("Rental request not found.");

        if (rentalRequest.Status != RequestStatus.Completed)
            throw new BusinessRuleViolationException(
                "Can only review after the transaction is completed.");

        if (reviewerId != rentalRequest.RequesterId && reviewerId != rentalRequest.OwnerId)
            throw new ForbiddenException("You are not a participant in this transaction.");

        // Each user can review the other exactly once per rental request
        var existingReview = rentalRequest.Reviews
            .FirstOrDefault(r => r.ReviewerId == reviewerId);

        if (existingReview is not null)
            throw new BusinessRuleViolationException("You have already reviewed this transaction.");

        // Determine the reviewee (the other participant)
        var revieweeId = reviewerId == rentalRequest.RequesterId
            ? rentalRequest.OwnerId
            : rentalRequest.RequesterId;

        // Calculate reputation delta: (Rating - 3) * 10
        var reputationDelta = (request.Rating - 3) * 10m;

        var review = new Review
        {
            Id = Guid.NewGuid(),
            RentalRequestId = rentalRequestId,
            ReviewerId = reviewerId,
            RevieweeId = revieweeId,
            Rating = request.Rating,
            Comment = request.Comment?.Trim(),
            ReputationDelta = reputationDelta,
            CreatedAt = DateTime.UtcNow
        };

        _context.Reviews.Add(review);

        // Update reviewee's reputation
        var reviewee = await _context.Users.FindAsync(revieweeId);
        if (reviewee is not null)
        {
            reviewee.ReputationScore = Math.Max(0, reviewee.ReputationScore + reputationDelta);
            reviewee.TotalReviews++;
            reviewee.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();

        // Load reviewer info for the DTO
        var reviewer = reviewerId == rentalRequest.RequesterId
            ? rentalRequest.Requester
            : rentalRequest.Owner;

        // Notify reviewee
        if (revieweeId != reviewerId)
        {
            await _notificationService.CreateNotificationAsync(
                revieweeId,
                NotificationType.Review,
                "Bạn nhận được đánh giá mới",
                $"{reviewer.FullName} đã đánh giá bạn {request.Rating}/5 sao.",
                review.Id,
                "Review");
        }

        return new ReviewDto
        {
            Id = review.Id,
            RentalRequestId = review.RentalRequestId,
            ReviewerId = review.ReviewerId,
            ReviewerName = reviewer.FullName,
            ReviewerAvatarUrl = reviewer.AvatarUrl,
            Rating = review.Rating,
            Comment = review.Comment,
            ReputationDelta = review.ReputationDelta,
            CreatedAt = review.CreatedAt
        };
    }
}
