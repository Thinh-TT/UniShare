namespace UniShare.API.Models.DTOs.Interactions;

public class CommentDto
{
    public Guid Id { get; set; }
    public Guid ListingId { get; set; }
    public Guid UserId { get; set; }
    public string UserName { get; set; } = null!;
    public string? UserAvatarUrl { get; set; }
    public Guid? ParentCommentId { get; set; }
    public string Content { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
