using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.RentalRequests;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1")]
[ApiExplorerSettings(GroupName = "RentalRequests")]
public class RentalRequestsController : ControllerBase
{
    private readonly IRentalService _rentalService;

    public RentalRequestsController(IRentalService rentalService)
    {
        _rentalService = rentalService;
    }

    /// <summary>Create a new rental request for a listing.</summary>
    [HttpPost("listings/{listingId:guid}/rental-requests")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateRentalRequest(
        Guid listingId, [FromBody] CreateRentalRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.CreateRentalRequestAsync(listingId, userId, request);
        return StatusCode(201, result);
    }

    /// <summary>List current user's rental requests. Filter by ?role=requester|owner&amp;status=Pending</summary>
    [HttpGet("me/rental-requests")]
    [Authorize]
    [ProducesResponseType(typeof(PagedResponse<RentalRequestSummaryDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    public async Task<IActionResult> GetMyRentalRequests(
        [FromQuery] string? role,
        [FromQuery] string? status,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.GetMyRentalRequestsAsync(userId, role, status, page, pageSize);
        return Ok(result);
    }

    /// <summary>Get full detail of a rental request.</summary>
    [HttpGet("rental-requests/{requestId:guid}")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetRentalRequest(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.GetRentalRequestDetailAsync(requestId, userId);
        return Ok(result);
    }

    /// <summary>Owner accepts a pending rental request.</summary>
    [HttpPatch("rental-requests/{requestId:guid}/accept")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> AcceptRequest(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.AcceptRequestAsync(requestId, userId);
        return Ok(result);
    }

    /// <summary>Owner rejects a pending rental request.</summary>
    [HttpPatch("rental-requests/{requestId:guid}/reject")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> RejectRequest(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.RejectRequestAsync(requestId, userId);
        return Ok(result);
    }

    /// <summary>Requester cancels a pending or accepted rental request.</summary>
    [HttpPatch("rental-requests/{requestId:guid}/cancel")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CancelRequest(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.CancelRequestAsync(requestId, userId);
        return Ok(result);
    }

    /// <summary>Owner starts the transaction (Accepted → InProgress).</summary>
    [HttpPatch("rental-requests/{requestId:guid}/start")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> StartTransaction(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.StartTransactionAsync(requestId, userId);
        return Ok(result);
    }

    /// <summary>Complete the transaction (InProgress → Completed). Either participant can trigger.</summary>
    [HttpPatch("rental-requests/{requestId:guid}/complete")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<RentalRequestDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CompleteTransaction(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _rentalService.CompleteTransactionAsync(requestId, userId);
        return Ok(result);
    }
}
