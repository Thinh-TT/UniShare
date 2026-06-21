using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models.DTOs.Deposits;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class DepositService : IDepositService
{
    private readonly AppDbContext _context;
    private readonly INotificationService _notificationService;

    public DepositService(AppDbContext context, INotificationService notificationService)
    {
        _context = context;
        _notificationService = notificationService;
    }

    public async Task<DepositDto> GetDepositByRequestAsync(Guid requestId, Guid userId)
    {
        var request = await _context.RentalRequests
            .Include(r => r.Deposit)
            .FirstOrDefaultAsync(r => r.Id == requestId);

        if (request is null)
            throw new NotFoundException("Rental request not found.");

        if (request.RequesterId != userId && request.OwnerId != userId)
            throw new ForbiddenException("You can only view deposits for your own rental requests.");

        if (request.Deposit is null)
            throw new NotFoundException("No deposit exists for this rental request.");

        return MapToDto(request.Deposit);
    }

    public async Task<DepositDto> MarkAsPaidAsync(Guid depositId, Guid userId)
    {
        var deposit = await _context.Deposits
            .Include(d => d.RentalRequest)
            .ThenInclude(r => r.Requester)
            .FirstOrDefaultAsync(d => d.Id == depositId);

        if (deposit is null)
            throw new NotFoundException("Deposit not found.");

        if (deposit.RentalRequest.OwnerId != userId)
            throw new ForbiddenException("Only the listing owner can mark a deposit as paid.");

        if (deposit.Status != DepositStatus.Pending)
            throw new BusinessRuleViolationException(
                $"Cannot mark deposit as paid. Current status is {deposit.Status}.");

        deposit.Status = DepositStatus.Paid;
        deposit.PaidAt = DateTime.UtcNow;
        deposit.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Notify requester
        if (deposit.RentalRequest.RequesterId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                deposit.RentalRequest.RequesterId,
                NotificationType.RequestStatus,
                "Tiền cọc đã được xác nhận",
                $"Tiền cọc {deposit.Amount:N0}đ cho giao dịch thuê đã được xác nhận.",
                deposit.RentalRequestId,
                "RentalRequest");
        }

        return MapToDto(deposit);
    }

    public async Task<DepositDto> RefundDepositAsync(Guid depositId, Guid userId)
    {
        var deposit = await _context.Deposits
            .Include(d => d.RentalRequest)
            .ThenInclude(r => r.Requester)
            .FirstOrDefaultAsync(d => d.Id == depositId);

        if (deposit is null)
            throw new NotFoundException("Deposit not found.");

        if (deposit.RentalRequest.OwnerId != userId)
            throw new ForbiddenException("Only the listing owner can refund a deposit.");

        if (deposit.Status != DepositStatus.Paid)
            throw new BusinessRuleViolationException(
                $"Cannot refund deposit. Current status is {deposit.Status}. Must be Paid.");

        if (deposit.RentalRequest.Status != RequestStatus.Completed)
            throw new BusinessRuleViolationException(
                "Can only refund deposit after the transaction is completed.");

        deposit.Status = DepositStatus.Refunded;
        deposit.RefundedAt = DateTime.UtcNow;
        deposit.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Notify requester
        if (deposit.RentalRequest.RequesterId != userId)
        {
            await _notificationService.CreateNotificationAsync(
                deposit.RentalRequest.RequesterId,
                NotificationType.RequestStatus,
                "Tiền cọc đã được hoàn",
                $"Tiền cọc {deposit.Amount:N0}đ cho giao dịch thuê đã được hoàn trả.",
                deposit.RentalRequestId,
                "RentalRequest");
        }

        return MapToDto(deposit);
    }

    // --- Mapper ---

    private static DepositDto MapToDto(Deposit deposit) => new()
    {
        Id = deposit.Id,
        RentalRequestId = deposit.RentalRequestId,
        Amount = deposit.Amount,
        Status = deposit.Status.ToString(),
        PaymentProvider = deposit.PaymentProvider,
        ProviderTransactionId = deposit.ProviderTransactionId,
        PaidAt = deposit.PaidAt,
        RefundedAt = deposit.RefundedAt,
        CreatedAt = deposit.CreatedAt
    };
}
