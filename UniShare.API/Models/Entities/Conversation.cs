using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Conversation : BaseEntity
{
    public Guid ListingId { get; set; }
    public Guid? RentalRequestId { get; set; }
    public Guid OwnerId { get; set; }
    public Guid RequesterId { get; set; }

    public DateTime? LastMessageAt { get; set; }

    // Navigation properties
    public Listing Listing { get; set; } = null!;
    public RentalRequest? RentalRequest { get; set; }
    public User Owner { get; set; } = null!;
    public User Requester { get; set; } = null!;

    public ICollection<Message> Messages { get; set; } = new List<Message>();
}
