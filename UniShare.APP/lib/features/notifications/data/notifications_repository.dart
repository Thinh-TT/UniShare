import '../../../core/network/api_response.dart';
import '../../notifications/models/notification_dto.dart';
import 'notifications_api.dart';

/// Business logic orchestration for notifications.
class NotificationsRepository {
  final NotificationsApi _notificationsApi;

  NotificationsRepository({required NotificationsApi notificationsApi})
      : _notificationsApi = notificationsApi;

  Future<PagedResponse<NotificationDto>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) {
    return _notificationsApi.getNotifications(page: page, pageSize: pageSize);
  }

  Future<int> getUnreadCount() {
    return _notificationsApi.getUnreadCount();
  }

  Future<void> markRead(String notificationId) {
    return _notificationsApi.markRead(notificationId);
  }

  Future<void> markAllRead() {
    return _notificationsApi.markAllRead();
  }
}
