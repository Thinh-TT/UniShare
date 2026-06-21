using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Users;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[ApiExplorerSettings(GroupName = "Users")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    /// <summary>Get current user's full profile</summary>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UserProfileResponse>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetMyProfile()
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _userService.GetProfileAsync(userId);
        return Ok(result);
    }

    /// <summary>Update current user's profile</summary>
    [HttpPut("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UserProfileResponse>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateProfileRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _userService.UpdateProfileAsync(userId, request);
        return Ok(result);
    }

    /// <summary>Get a user's public profile</summary>
    [HttpGet("{userId:guid}")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<UserSummaryDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetUser(Guid userId)
    {
        var result = await _userService.GetUserSummaryAsync(userId);
        return Ok(result);
    }

    /// <summary>Get a user's reviews</summary>
    [HttpGet("{userId:guid}/reviews")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(PagedResponse<UserReviewDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetUserReviews(
        Guid userId, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var (items, totalCount) = await _userService.GetUserReviewsAsync(userId, page, pageSize);

        return Ok(new PagedResponse<UserReviewDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        });
    }
}
