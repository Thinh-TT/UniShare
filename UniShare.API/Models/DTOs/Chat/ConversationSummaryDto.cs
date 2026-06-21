namespace UniShare.API.Models.DTOs.Chat;

public class ConversationSummaryDto
{
    public Guid Id { get; set; }
    public Guid ListingId { get; set; }
    public string ListingTitle { get; set; } = null!;
    public string? ListingImageUrl { get; set; }
    public Guid OtherParticipantId { get; set; }
    public string OtherParticipantName { get; set; } = null!;
    public string? OtherParticipantAvatarUrl { get; set; }
    public string? LastMessageContent { get; set; }
    public Guid? LastMessageSenderId { get; set; }
    public DateTime? LastMessageAt { get; set; }
    public int UnreadCount { get; set; }
    public DateTime CreatedAt { get; set; }
}
