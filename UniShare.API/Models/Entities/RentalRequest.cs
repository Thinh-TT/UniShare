using UniShare.API.Models.Entities.Base;
using UniShare.API.Models.Enums;

namespace UniShare.API.Models.Entities;

public class RentalRequest : BaseEntity
{
    public Guid ListingId { get; set; }
    public Guid RequesterId { get; set; }
    public Guid OwnerId { get; set; }

    public RequestStatus Status { get; set; } = RequestStatus.Pending;

    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string? Message { get; set; }

    public decimal TotalPrice { get; set; }
    public decimal? DepositAmount { get; set; }

    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public Listing Listing { get; set; } = null!;
    public User Requester { get; set; } = null!;
    public User Owner { get; set; } = null!;

    public Deposit? Deposit { get; set; }
    public ICollection<Conversation> Conversations { get; set; } = new List<Conversation>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
