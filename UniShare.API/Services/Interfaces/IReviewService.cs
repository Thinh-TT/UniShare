using UniShare.API.Models.DTOs.Reviews;

namespace UniShare.API.Services.Interfaces;

public interface IReviewService
{
    /// <summary>
    /// Create a review after a completed rental transaction.
    /// Each participant may review the other exactly once per request.
    /// Updates the reviewee's ReputationScore and TotalReviews.
    /// </summary>
    Task<ReviewDto> CreateReviewAsync(
        Guid rentalRequestId, Guid reviewerId, CreateReviewRequest request);
}
