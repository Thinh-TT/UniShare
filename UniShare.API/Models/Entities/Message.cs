using UniShare.API.Models.Entities.Base;
using UniShare.API.Models.Enums;

namespace UniShare.API.Models.Entities;

public class Message : BaseEntity, ISoftDeletable
{
    public Guid ConversationId { get; set; }
    public Guid SenderId { get; set; }

    public string Content { get; set; } = null!;
    public MessageStatus Status { get; set; } = MessageStatus.Sent;

    public DateTime? ReadAt { get; set; }
    public DateTime? DeletedAt { get; set; }

    // Navigation properties
    public Conversation Conversation { get; set; } = null!;
    public User Sender { get; set; } = null!;
}
