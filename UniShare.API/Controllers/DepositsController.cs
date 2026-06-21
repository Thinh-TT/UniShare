using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Deposits;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1")]
[ApiExplorerSettings(GroupName = "RentalRequests")]
public class DepositsController : ControllerBase
{
    private readonly IDepositService _depositService;

    public DepositsController(IDepositService depositService)
    {
        _depositService = depositService;
    }

    /// <summary>Get the deposit associated with a rental request.</summary>
    [HttpGet("rental-requests/{requestId:guid}/deposit")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<DepositDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetDeposit(Guid requestId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _depositService.GetDepositByRequestAsync(requestId, userId);
        return Ok(result);
    }

    /// <summary>Owner marks a deposit as paid.</summary>
    [HttpPatch("deposits/{depositId:guid}/mark-paid")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<DepositDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> MarkDepositPaid(Guid depositId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _depositService.MarkAsPaidAsync(depositId, userId);
        return Ok(result);
    }

    /// <summary>Owner refunds a deposit. Only allowed after transaction completes.</summary>
    [HttpPatch("deposits/{depositId:guid}/refund")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<DepositDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> RefundDeposit(Guid depositId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _depositService.RefundDepositAsync(depositId, userId);
        return Ok(result);
    }
}
