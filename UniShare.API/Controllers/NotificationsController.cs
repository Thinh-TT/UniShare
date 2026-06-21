using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Notifications;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1/me")]
[ApiExplorerSettings(GroupName = "Notifications")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    /// <summary>List the current user's notifications with optional filters.</summary>
    [HttpGet("notifications")]
    [Authorize]
    [ProducesResponseType(typeof(PagedResponse<NotificationDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    public async Task<IActionResult> GetNotifications([FromQuery] NotificationFilterParams filter)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _notificationService.GetNotificationsAsync(userId, filter);
        return Ok(result);
    }

    /// <summary>Get unread notification count for the current user.</summary>
    [HttpGet("notifications/unread-count")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<int>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    public async Task<IActionResult> GetUnreadCount()
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var count = await _notificationService.GetUnreadCountAsync(userId);
        return Ok(count);
    }

    /// <summary>Mark a single notification as read.</summary>
    [HttpPatch("notifications/{notificationId:guid}/read")]
    [Authorize]
    [ProducesResponseType(204)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> MarkAsRead(Guid notificationId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _notificationService.MarkAsReadAsync(userId, notificationId);
        return NoContent();
    }

    /// <summary>Mark all notifications as read for the current user.</summary>
    [HttpPatch("notifications/read-all")]
    [Authorize]
    [ProducesResponseType(204)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _notificationService.MarkAllAsReadAsync(userId);
        return NoContent();
    }
}
