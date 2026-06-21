using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Hubs;

[Authorize]
public class ChatHub : Hub
{
    private readonly IChatService _chatService;

    public ChatHub(IChatService chatService)
    {
        _chatService = chatService;
    }

    /// <summary>Join a conversation group to receive realtime message updates.</summary>
    public async Task JoinConversation(Guid conversationId)
    {
        var userId = GetUserId();

        // Validate user is a participant before allowing group join
        await _chatService.GetConversationDetailAsync(conversationId, userId);

        await Groups.AddToGroupAsync(Context.ConnectionId, conversationId.ToString());
    }

    /// <summary>Leave a conversation group.</summary>
    public async Task LeaveConversation(Guid conversationId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, conversationId.ToString());
    }

    /// <summary>Send a message in realtime. Persists to database and broadcasts to all participants.</summary>
    public async Task SendMessage(Guid conversationId, string content)
    {
        var userId = GetUserId();

        // Persist via service layer (includes notification creation)
        var messageDto = await _chatService.SendMessageAsync(conversationId, userId, content);

        // Broadcast new message to all participants viewing this conversation
        await Clients.Group(conversationId.ToString())
            .SendAsync("MessageReceived", messageDto);

        // Broadcast updated conversation summary so participants can refresh their list
        var conversation = await _chatService.GetConversationDetailAsync(conversationId, userId);
        var summaryForOwner = await _chatService.GetConversationSummaryAsync(conversationId, conversation.OwnerId);
        var summaryForRequester = await _chatService.GetConversationSummaryAsync(conversationId, conversation.RequesterId);

        // Both participants are in the same group — each client filters by OtherParticipantId if needed
        await Clients.Group(conversationId.ToString())
            .SendAsync("ConversationUpdated", new
            {
                OwnerSummary = summaryForOwner,
                RequesterSummary = summaryForRequester
            });
    }

    /// <summary>Mark all unread messages in a conversation as read.</summary>
    public async Task MarkAsRead(Guid conversationId)
    {
        var userId = GetUserId();

        var count = await _chatService.MarkMessagesAsReadAsync(conversationId, userId);

        if (count > 0)
        {
            // Notify other participants that messages were read
            await Clients.Group(conversationId.ToString())
                .SendAsync("MessageRead", new
                {
                    ConversationId = conversationId,
                    ReadByUserId = userId,
                    ReadAt = DateTime.UtcNow
                });
        }
    }

    // --- Private helpers ---

    private Guid GetUserId()
    {
        return Guid.Parse(Context.User!.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    }
}
