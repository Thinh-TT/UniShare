using UniShare.API.Models;
using UniShare.API.Models.DTOs.Interactions;

namespace UniShare.API.Services.Interfaces;

public interface IInteractionService
{
    Task<UpvoteResponse> UpvoteAsync(Guid listingId, Guid userId);
    Task<UpvoteResponse> RemoveUpvoteAsync(Guid listingId, Guid userId);
    Task<PagedResponse<CommentDto>> GetCommentsAsync(Guid listingId, int page, int pageSize);
    Task<CommentDto> CreateCommentAsync(Guid listingId, Guid userId, CreateCommentRequest request);
    Task<CommentDto> UpdateCommentAsync(Guid commentId, Guid userId, UpdateCommentRequest request);
    Task SoftDeleteCommentAsync(Guid commentId, Guid userId, bool isAdmin);
}
