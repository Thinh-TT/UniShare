using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class User : BaseEntity
{
    public string Email { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string PasswordHash { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string? AvatarUrl { get; set; }
    public string Role { get; set; } = "User";

    public Guid? SchoolId { get; set; }
    public Guid? AreaId { get; set; }

    public decimal ReputationScore { get; set; } = 100.00m;
    public int TotalReviews { get; set; } = 0;
    public bool IsVerified { get; set; } = false;
    public bool IsActive { get; set; } = true;

    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public School? School { get; set; }
    public Area? Area { get; set; }

    public ICollection<Listing> Listings { get; set; } = new List<Listing>();
    public ICollection<Upvote> Upvotes { get; set; } = new List<Upvote>();
    public ICollection<Comment> Comments { get; set; } = new List<Comment>();
    public ICollection<RentalRequest> RentalRequestsAsRequester { get; set; } = new List<RentalRequest>();
    public ICollection<RentalRequest> RentalRequestsAsOwner { get; set; } = new List<RentalRequest>();
    public ICollection<Conversation> ConversationsAsOwner { get; set; } = new List<Conversation>();
    public ICollection<Conversation> ConversationsAsRequester { get; set; } = new List<Conversation>();
    public ICollection<Message> Messages { get; set; } = new List<Message>();
    public ICollection<Review> ReviewsAsReviewer { get; set; } = new List<Review>();
    public ICollection<Review> ReviewsAsReviewee { get; set; } = new List<Review>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
}
