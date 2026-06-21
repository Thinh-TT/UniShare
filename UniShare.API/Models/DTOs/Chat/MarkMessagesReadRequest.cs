namespace UniShare.API.Models.DTOs.Chat;

/// <summary>
/// Request to mark messages as read in a conversation.
/// Currently marks all unread messages; lastReadMessageId is reserved for future fine-grained read receipts.
/// </summary>
public class MarkMessagesReadRequest
{
    public Guid? LastReadMessageId { get; set; }
}
