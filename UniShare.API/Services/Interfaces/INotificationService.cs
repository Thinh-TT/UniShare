using UniShare.API.Models;
using UniShare.API.Models.DTOs.Notifications;
using UniShare.API.Models.Enums;

namespace UniShare.API.Services.Interfaces;

public interface INotificationService
{
    /// <summary>
    /// Creates a notification for a user. If the real-time hub is connected,
    /// the notification is also pushed via SignalR.
    /// </summary>
    Task<NotificationDto> CreateNotificationAsync(
        Guid userId,
        NotificationType type,
        string title,
        string body,
        Guid? referenceId = null,
        string? referenceType = null);

    /// <summary>
    /// Returns a paginated list of notifications for the current user,
    /// with optional filters by read status and type.
    /// </summary>
    Task<PagedResponse<NotificationDto>> GetNotificationsAsync(
        Guid userId,
        NotificationFilterParams filter);

    /// <summary>
    /// Returns the count of unread notifications for the current user.
    /// </summary>
    Task<int> GetUnreadCountAsync(Guid userId);

    /// <summary>
    /// Marks a single notification as read. Throws ForbiddenException
    /// if the notification does not belong to the user.
    /// </summary>
    Task MarkAsReadAsync(Guid userId, Guid notificationId);

    /// <summary>
    /// Marks all notifications for the current user as read.
    /// </summary>
    Task MarkAllAsReadAsync(Guid userId);
}
