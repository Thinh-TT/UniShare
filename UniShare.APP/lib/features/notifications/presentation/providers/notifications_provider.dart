import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/notifications_api.dart';
import '../../data/notifications_repository.dart';
import '../../models/notification_dto.dart';

/// Provider for NotificationsApi singleton.
final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for NotificationsRepository singleton.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(
    notificationsApi: ref.read(notificationsApiProvider),
  );
});

/// State for the notifications list screen.
class NotificationsState {
  final List<NotificationDto> notifications;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<NotificationDto>? notifications,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for the notifications list screen.
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsNotifier(this._repository) : super(const NotificationsState());

  /// Load the first page of notifications.
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        notifications: [],
        currentPage: 1,
        hasMore: true,
      );
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final response = await _repository.getNotifications(page: 1);

      state = state.copyWith(
        notifications: response.items,
        currentPage: 1,
        isLoading: false,
        hasMore: response.hasMore,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông báo. ${e.toString()}',
      );
    }
  }

  /// Load the next page (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getNotifications(page: nextPage);

      state = state.copyWith(
        notifications: [...state.notifications, ...response.items],
        currentPage: nextPage,
        isLoadingMore: false,
        hasMore: response.hasMore,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Không thể tải thêm. ${e.toString()}',
      );
    }
  }

  /// Mark a single notification as read (optimistic).
  Future<void> markAsRead(String notificationId) async {
    // Optimistic update
    final oldNotifications = List<NotificationDto>.from(state.notifications);
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationDto(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            referenceId: n.referenceId,
            referenceType: n.referenceType,
            isRead: true,
            createdAt: n.createdAt,
            readAt: DateTime.now(),
          );
        }
        return n;
      }).toList(),
    );

    try {
      await _repository.markRead(notificationId);
    } on Exception {
      // Revert on failure
      state = state.copyWith(notifications: oldNotifications);
    }
  }

  /// Mark all notifications as read (optimistic).
  Future<void> markAllAsRead() async {
    final oldNotifications = List<NotificationDto>.from(state.notifications);
    final now = DateTime.now();
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (!n.isRead) {
          return NotificationDto(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            referenceId: n.referenceId,
            referenceType: n.referenceType,
            isRead: true,
            createdAt: n.createdAt,
            readAt: now,
          );
        }
        return n;
      }).toList(),
    );

    try {
      await _repository.markAllRead();
    } on Exception {
      // Revert on failure
      state = state.copyWith(notifications: oldNotifications);
    }
  }
}

/// Provider for the notifications list screen.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(notificationsRepositoryProvider));
});

/// Provider for the unread notification count.
final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.read(notificationsRepositoryProvider);
  return repository.getUnreadCount();
});
