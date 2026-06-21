using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Interactions;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1")]
[ApiExplorerSettings(GroupName = "Interactions")]
public class InteractionsController : ControllerBase
{
    private readonly IInteractionService _interactionService;

    public InteractionsController(IInteractionService interactionService)
    {
        _interactionService = interactionService;
    }

    /// <summary>Upvote a listing (idempotent — calling again has no effect)</summary>
    [HttpPut("listings/{listingId:guid}/upvote")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UpvoteResponse>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> Upvote(Guid listingId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _interactionService.UpvoteAsync(listingId, userId);
        return Ok(result);
    }

    /// <summary>Remove an upvote from a listing (idempotent — calling without prior upvote has no effect)</summary>
    [HttpDelete("listings/{listingId:guid}/upvote")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<UpvoteResponse>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> RemoveUpvote(Guid listingId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _interactionService.RemoveUpvoteAsync(listingId, userId);
        return Ok(result);
    }

    /// <summary>Get comments for a listing (paginated, newest first)</summary>
    [HttpGet("listings/{listingId:guid}/comments")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(PagedResponse<CommentDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetComments(
        Guid listingId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var result = await _interactionService.GetCommentsAsync(listingId, page, pageSize);
        return Ok(result);
    }

    /// <summary>Create a comment on a listing (optionally replying to another comment)</summary>
    [HttpPost("listings/{listingId:guid}/comments")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<CommentDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateComment(Guid listingId, [FromBody] CreateCommentRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _interactionService.CreateCommentAsync(listingId, userId, request);
        return StatusCode(201, result);
    }

    /// <summary>Update own comment content</summary>
    [HttpPut("comments/{commentId:guid}")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<CommentDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> UpdateComment(Guid commentId, [FromBody] UpdateCommentRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _interactionService.UpdateCommentAsync(commentId, userId, request);
        return Ok(result);
    }

    /// <summary>Soft-delete a comment (owner or admin only)</summary>
    [HttpDelete("comments/{commentId:guid}")]
    [Authorize]
    [ProducesResponseType(204)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> DeleteComment(Guid commentId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var isAdmin = User.IsInRole("Admin");
        await _interactionService.SoftDeleteCommentAsync(commentId, userId, isAdmin);
        return NoContent();
    }
}
