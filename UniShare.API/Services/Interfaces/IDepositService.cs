using UniShare.API.Models.DTOs.Deposits;

namespace UniShare.API.Services.Interfaces;

public interface IDepositService
{
    /// <summary>Get the deposit for a rental request. Only requester or owner may view.</summary>
    Task<DepositDto> GetDepositByRequestAsync(Guid requestId, Guid userId);

    /// <summary>Owner marks a deposit as Paid. Requires deposit status = Pending.</summary>
    Task<DepositDto> MarkAsPaidAsync(Guid depositId, Guid userId);

    /// <summary>Owner refunds a deposit. Requires deposit status = Paid and request Completed.</summary>
    Task<DepositDto> RefundDepositAsync(Guid depositId, Guid userId);
}
