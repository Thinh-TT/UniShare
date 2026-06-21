using UniShare.API.Models.Entities.Base;
using UniShare.API.Models.Enums;

namespace UniShare.API.Models.Entities;

public class Listing : BaseEntity, ISoftDeletable
{
    public Guid OwnerId { get; set; }
    public Guid CategoryId { get; set; }
    public Guid? SchoolId { get; set; }
    public Guid? AreaId { get; set; }

    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public ListingType ListingType { get; set; }
    public ListingStatus Status { get; set; } = ListingStatus.Draft;

    public decimal PricePerDay { get; set; }
    public decimal? DepositAmount { get; set; }
    public string? ConditionNote { get; set; }

    public int ViewCount { get; set; } = 0;
    public int UpvoteCount { get; set; } = 0;
    public int CommentCount { get; set; } = 0;

    public DateTime? UpdatedAt { get; set; }
    public DateTime? DeletedAt { get; set; }

    // Navigation properties
    public User Owner { get; set; } = null!;
    public Category Category { get; set; } = null!;
    public School? School { get; set; }
    public Area? Area { get; set; }

    public ICollection<ListingImage> Images { get; set; } = new List<ListingImage>();
    public ICollection<ListingTag> ListingTags { get; set; } = new List<ListingTag>();
    public ICollection<Upvote> Upvotes { get; set; } = new List<Upvote>();
    public ICollection<Comment> Comments { get; set; } = new List<Comment>();
    public ICollection<RentalRequest> RentalRequests { get; set; } = new List<RentalRequest>();
    public ICollection<Conversation> Conversations { get; set; } = new List<Conversation>();
}
