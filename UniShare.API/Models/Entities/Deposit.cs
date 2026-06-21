using UniShare.API.Models.Entities.Base;
using UniShare.API.Models.Enums;

namespace UniShare.API.Models.Entities;

public class Deposit : BaseEntity
{
    public Guid RentalRequestId { get; set; }
    public decimal Amount { get; set; }
    public DepositStatus Status { get; set; } = DepositStatus.None;

    public string? PaymentProvider { get; set; }
    public string? ProviderTransactionId { get; set; }

    public DateTime? PaidAt { get; set; }
    public DateTime? RefundedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public RentalRequest RentalRequest { get; set; } = null!;
}
