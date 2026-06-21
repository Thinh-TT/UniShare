namespace UniShare.API.Models.DTOs.Chat;

public class MessageDto
{
    public Guid Id { get; set; }
    public Guid ConversationId { get; set; }
    public Guid SenderId { get; set; }
    public string SenderName { get; set; } = null!;
    public string? SenderAvatarUrl { get; set; }
    public string Content { get; set; } = null!;
    public string Status { get; set; } = null!;
    public DateTime? ReadAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
