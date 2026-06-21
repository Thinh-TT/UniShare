namespace UniShare.API.Models.DTOs.Chat;

public class ConversationDetailDto
{
    public Guid Id { get; set; }
    public Guid ListingId { get; set; }
    public string ListingTitle { get; set; } = null!;
    public string? ListingImageUrl { get; set; }
    public Guid OwnerId { get; set; }
    public string OwnerName { get; set; } = null!;
    public string? OwnerAvatarUrl { get; set; }
    public Guid RequesterId { get; set; }
    public string RequesterName { get; set; } = null!;
    public string? RequesterAvatarUrl { get; set; }
    public string? LastMessageContent { get; set; }
    public Guid? LastMessageSenderId { get; set; }
    public DateTime? LastMessageAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
