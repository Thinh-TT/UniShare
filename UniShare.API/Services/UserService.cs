using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models.DTOs.Users;
using UniShare.API.Models.Entities;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _context;

    public UserService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<UserProfileResponse> GetProfileAsync(Guid userId)
    {
        var user = await _context.Users
            .Include(u => u.School)
            .Include(u => u.Area)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            throw new NotFoundException("User not found");

        return MapToProfile(user);
    }

    public async Task<UserProfileResponse> UpdateProfileAsync(Guid userId, UpdateProfileRequest request)
    {
        var user = await _context.Users
            .Include(u => u.School)
            .Include(u => u.Area)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            throw new NotFoundException("User not found");

        // Update only provided fields
        if (request.FullName is not null)
            user.FullName = request.FullName;

        if (request.PhoneNumber is not null)
        {
            // Check phone uniqueness excluding current user
            if (await _context.Users.AnyAsync(u =>
                    u.PhoneNumber == request.PhoneNumber && u.Id != userId))
                throw new DuplicatePhoneException("Phone number is already in use");
            user.PhoneNumber = request.PhoneNumber;
        }

        if (request.AvatarUrl is not null)
            user.AvatarUrl = request.AvatarUrl;

        if (request.SchoolId.HasValue)
        {
            var school = await _context.Schools
                .FirstOrDefaultAsync(s => s.Id == request.SchoolId.Value && s.IsActive);
            if (school is null)
                throw new NotFoundException("School not found or inactive");
            user.SchoolId = request.SchoolId;
        }

        if (request.AreaId.HasValue)
        {
            var area = await _context.Areas
                .FirstOrDefaultAsync(a => a.Id == request.AreaId.Value && a.IsActive);
            if (area is null)
                throw new NotFoundException("Area not found or inactive");
            user.AreaId = request.AreaId;
        }

        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        // Re-load navigation properties for the response
        await _context.Entry(user).Reference(u => u.School).LoadAsync();
        await _context.Entry(user).Reference(u => u.Area).LoadAsync();

        return MapToProfile(user);
    }

    public async Task<UserSummaryDto> GetUserSummaryAsync(Guid userId)
    {
        var user = await _context.Users
            .Include(u => u.School)
            .Include(u => u.Area)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            throw new NotFoundException("User not found");

        return new UserSummaryDto
        {
            Id = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            AvatarUrl = user.AvatarUrl,
            ReputationScore = user.ReputationScore,
            TotalReviews = user.TotalReviews,
            SchoolName = user.School?.Name,
            AreaName = user.Area?.Name
        };
    }

    public async Task<(List<UserReviewDto> Items, int TotalCount)> GetUserReviewsAsync(
        Guid userId, int page = 1, int pageSize = 10)
    {
        // Verify user exists
        if (!await _context.Users.AnyAsync(u => u.Id == userId))
            throw new NotFoundException("User not found");

        var query = _context.Reviews
            .Include(r => r.Reviewer)
            .Where(r => r.RevieweeId == userId);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(r => r.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new UserReviewDto
            {
                Id = r.Id,
                Rating = r.Rating,
                Comment = r.Comment,
                ReviewerName = r.Reviewer.FullName,
                ReviewerAvatarUrl = r.Reviewer.AvatarUrl,
                CreatedAt = r.CreatedAt
            })
            .ToListAsync();

        return (items, totalCount);
    }

    private static UserProfileResponse MapToProfile(User user) => new()
    {
        Id = user.Id,
        Email = user.Email,
        PhoneNumber = user.PhoneNumber,
        FullName = user.FullName,
        AvatarUrl = user.AvatarUrl,
        SchoolId = user.SchoolId,
        SchoolName = user.School?.Name,
        AreaId = user.AreaId,
        AreaName = user.Area?.Name,
        ReputationScore = user.ReputationScore,
        TotalReviews = user.TotalReviews,
        IsVerified = user.IsVerified,
        CreatedAt = user.CreatedAt,
        UpdatedAt = user.UpdatedAt
    };
}
