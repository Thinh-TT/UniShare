using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Hubs;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Notifications;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class NotificationService : INotificationService
{
    private readonly AppDbContext _context;
    private readonly IHubContext<NotificationHub> _hubContext;

    public NotificationService(AppDbContext context, IHubContext<NotificationHub> hubContext)
    {
        _context = context;
        _hubContext = hubContext;
    }

    public async Task<NotificationDto> CreateNotificationAsync(
        Guid userId,
        NotificationType type,
        string title,
        string body,
        Guid? referenceId = null,
        string? referenceType = null)
    {
        var notification = new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Type = type,
            Title = title,
            Body = body,
            ReferenceId = referenceId,
            ReferenceType = referenceType,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();

        var dto = MapToDto(notification);

        // Real-time push via SignalR to the user's personal group
        await _hubContext.Clients.Group(userId.ToString())
            .SendAsync("NotificationReceived", dto);

        return dto;
    }

    public async Task<PagedResponse<NotificationDto>> GetNotificationsAsync(
        Guid userId, NotificationFilterParams filter)
    {
        var page = Math.Max(1, filter.Page);
        var pageSize = Math.Clamp(filter.PageSize, 1, 50);

        var query = _context.Notifications
            .Where(n => n.UserId == userId);

        if (filter.IsRead.HasValue)
        {
            query = query.Where(n => n.IsRead == filter.IsRead.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.Type))
        {
            query = query.Where(n => n.Type == Enum.Parse<NotificationType>(filter.Type));
        }

        var totalItems = await query.CountAsync();

        var items = await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(n => MapToDto(n))
            .ToListAsync();

        return new PagedResponse<NotificationDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalItems
        };
    }

    public async Task<int> GetUnreadCountAsync(Guid userId)
    {
        return await _context.Notifications
            .CountAsync(n => n.UserId == userId && !n.IsRead);
    }

    public async Task MarkAsReadAsync(Guid userId, Guid notificationId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId);

        if (notification is null)
            throw new NotFoundException("Notification not found.");

        if (notification.UserId != userId)
            throw new ForbiddenException("You can only mark your own notifications as read.");

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsReadAsync(Guid userId)
    {
        var unread = await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync();

        foreach (var notification in unread)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
        }

        if (unread.Count > 0)
            await _context.SaveChangesAsync();
    }

    // --- Mapper ---

    private static NotificationDto MapToDto(Notification entity) => new()
    {
        Id = entity.Id,
        Type = entity.Type.ToString(),
        Title = entity.Title,
        Body = entity.Body,
        ReferenceId = entity.ReferenceId,
        ReferenceType = entity.ReferenceType,
        IsRead = entity.IsRead,
        ReadAt = entity.ReadAt,
        CreatedAt = entity.CreatedAt
    };
}
