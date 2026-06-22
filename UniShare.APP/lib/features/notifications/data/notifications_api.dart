import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../notifications/models/notification_dto.dart';

/// Low-level API calls for notifications.
class NotificationsApi {
  final ApiClient _apiClient;

  NotificationsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get paginated notifications.
  Future<PagedResponse<NotificationDto>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _apiClient.getPaged<NotificationDto>(
      path: ApiEndpoints.myNotifications,
      queryParams: {'page': page, 'pageSize': pageSize},
      fromJsonT: (json) => NotificationDto.fromJson(json),
    );
  }

  /// Get unread notification count.
  Future<int> getUnreadCount() async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.unreadCount,
    );
    return (response['data'] as Map<String, dynamic>)['unreadCount'] as int;
  }

  /// Mark a single notification as read.
  Future<void> markRead(String notificationId) async {
    await _apiClient.patch<void>(
      path: ApiEndpoints.markNotificationRead(notificationId),
      fromJsonT: (_) => null,
    );
  }

  /// Mark all notifications as read.
  Future<void> markAllRead() async {
    await _apiClient.patch<void>(
      path: ApiEndpoints.markAllNotificationsRead,
      fromJsonT: (_) => null,
    );
  }
}
