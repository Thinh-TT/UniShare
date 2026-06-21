using UniShare.API.Models.Entities.Base;
using UniShare.API.Models.Enums;

namespace UniShare.API.Models.Entities;

public class Notification : BaseEntity
{
    public Guid UserId { get; set; }
    public NotificationType Type { get; set; }
    public string Title { get; set; } = null!;
    public string Body { get; set; } = null!;

    public Guid? ReferenceId { get; set; }
    public string? ReferenceType { get; set; }

    public bool IsRead { get; set; } = false;
    public DateTime? ReadAt { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
}
