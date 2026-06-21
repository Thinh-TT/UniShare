using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using UniShare.API.Hubs;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Chat;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1")]
[ApiExplorerSettings(GroupName = "Chat")]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;
    private readonly IHubContext<ChatHub> _hubContext;

    public ChatController(IChatService chatService, IHubContext<ChatHub> hubContext)
    {
        _chatService = chatService;
        _hubContext = hubContext;
    }

    /// <summary>Create or open a conversation for a listing. Returns 200 for existing, 201 for new.</summary>
    [HttpPost("listings/{listingId:guid}/conversations")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<ConversationDetailDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse<ConversationDetailDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateConversation(
        Guid listingId, [FromBody] CreateConversationRequest? request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var (conversation, isNew) = await _chatService.CreateOrOpenConversationAsync(
            listingId, userId, request);
        return isNew ? StatusCode(201, conversation) : Ok(conversation);
    }

    /// <summary>List my conversations (paginated, most recent first).</summary>
    [HttpGet("me/conversations")]
    [Authorize]
    [ProducesResponseType(typeof(PagedResponse<ConversationSummaryDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    public async Task<IActionResult> GetMyConversations(
        [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.GetMyConversationsAsync(userId, page, pageSize);
        return Ok(result);
    }

    /// <summary>Get conversation detail (participant only).</summary>
    [HttpGet("conversations/{conversationId:guid}")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<ConversationDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetConversation(Guid conversationId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.GetConversationDetailAsync(conversationId, userId);
        return Ok(result);
    }

    /// <summary>Get messages for a conversation (paginated, newest first; participant only).</summary>
    [HttpGet("conversations/{conversationId:guid}/messages")]
    [Authorize]
    [ProducesResponseType(typeof(PagedResponse<MessageDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetMessages(
        Guid conversationId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.GetMessagesAsync(conversationId, userId, page, pageSize);
        return Ok(result);
    }

    /// <summary>Send a message via HTTP (fallback). Also broadcasts to SignalR-connected clients.</summary>
    [HttpPost("conversations/{conversationId:guid}/messages")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<MessageDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> SendMessage(
        Guid conversationId, [FromBody] SendMessageRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _chatService.SendMessageAsync(conversationId, userId, request.Content);

        // Broadcast to SignalR group so connected clients receive realtime updates
        await _hubContext.Clients.Group(conversationId.ToString())
            .SendAsync("MessageReceived", result);

        return StatusCode(201, result);
    }

    /// <summary>Mark all unread messages as read (participant only).</summary>
    [HttpPatch("conversations/{conversationId:guid}/messages/read")]
    [Authorize]
    [ProducesResponseType(204)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> MarkAsRead(Guid conversationId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var count = await _chatService.MarkMessagesAsReadAsync(conversationId, userId);

        if (count > 0)
        {
            // Notify other participant via SignalR
            await _hubContext.Clients.Group(conversationId.ToString())
                .SendAsync("MessageRead", new
                {
                    ConversationId = conversationId,
                    ReadByUserId = userId,
                    ReadAt = DateTime.UtcNow
                });
        }

        return NoContent();
    }
}
