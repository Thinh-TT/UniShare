using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Upvote : BaseEntity
{
    public Guid ListingId { get; set; }
    public Guid UserId { get; set; }

    // Navigation properties
    public Listing Listing { get; set; } = null!;
    public User User { get; set; } = null!;
}
