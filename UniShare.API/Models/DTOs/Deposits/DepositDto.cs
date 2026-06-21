namespace UniShare.API.Models.DTOs.Deposits;

public class DepositDto
{
    public Guid Id { get; set; }
    public Guid RentalRequestId { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; } = null!;
    public string? PaymentProvider { get; set; }
    public string? ProviderTransactionId { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? RefundedAt { get; set; }
    public DateTime CreatedAt { get; set; }
}
