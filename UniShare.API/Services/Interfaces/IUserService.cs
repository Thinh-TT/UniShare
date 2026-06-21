using UniShare.API.Models.DTOs.Users;

namespace UniShare.API.Services.Interfaces;

public interface IUserService
{
    Task<UserProfileResponse> GetProfileAsync(Guid userId);
    Task<UserProfileResponse> UpdateProfileAsync(Guid userId, UpdateProfileRequest request);
    Task<UserSummaryDto> GetUserSummaryAsync(Guid userId);
    Task<(List<UserReviewDto> Items, int TotalCount)> GetUserReviewsAsync(Guid userId, int page = 1, int pageSize = 10);
}
