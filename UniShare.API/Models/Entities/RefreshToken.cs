using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class RefreshToken : BaseEntity
{
    public Guid UserId { get; set; }
    public string Token { get; set; } = null!;
    public DateTime ExpiresAt { get; set; }
    public bool IsRevoked { get; set; } = false;
    public DateTime? RevokedAt { get; set; }

    // Navigation
    public User User { get; set; } = null!;
}
