using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Comment : BaseEntity, ISoftDeletable
{
    public Guid ListingId { get; set; }
    public Guid UserId { get; set; }
    public Guid? ParentCommentId { get; set; }

    public string Content { get; set; } = null!;

    public DateTime? UpdatedAt { get; set; }
    public DateTime? DeletedAt { get; set; }

    // Navigation properties
    public Listing Listing { get; set; } = null!;
    public User User { get; set; } = null!;
    public Comment? ParentComment { get; set; }
    public ICollection<Comment> Replies { get; set; } = new List<Comment>();
}
