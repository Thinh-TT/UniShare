using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Review : BaseEntity
{
    public Guid RentalRequestId { get; set; }
    public Guid ReviewerId { get; set; }
    public Guid RevieweeId { get; set; }

    public int Rating { get; set; }
    public string? Comment { get; set; }
    public decimal ReputationDelta { get; set; }

    // Navigation properties
    public RentalRequest RentalRequest { get; set; } = null!;
    public User Reviewer { get; set; } = null!;
    public User Reviewee { get; set; } = null!;
}
