import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unishare/core/network/api_response.dart';
import 'package:unishare/core/network/signalr_client.dart';
import 'package:unishare/config/app_config.dart';
import 'package:unishare/features/auth/presentation/providers/auth_provider.dart';
import 'package:unishare/features/auth/presentation/providers/auth_state.dart';
import 'package:unishare/features/users/models/user_profile_dto.dart';
import 'package:unishare/features/comments/models/comment_dto.dart';
import 'package:unishare/features/comments/models/create_comment_request.dart';
import 'package:unishare/features/comments/models/update_comment_request.dart';
import 'package:unishare/features/comments/data/comments_repository.dart';
import 'package:unishare/features/comments/presentation/providers/comments_provider.dart';
import 'package:unishare/features/comments/presentation/screens/comments_screen.dart';
import 'package:unishare/features/conversations/models/conversation_dto.dart';
import 'package:unishare/features/conversations/models/conversation_detail_dto.dart';
import 'package:unishare/features/conversations/models/message_dto.dart';
import 'package:unishare/features/conversations/data/conversations_repository.dart';
import 'package:unishare/features/conversations/presentation/providers/conversations_provider.dart';
import 'package:unishare/features/conversations/presentation/providers/chat_provider.dart';
import 'package:unishare/features/conversations/presentation/screens/conversation_list_screen.dart';
import 'package:unishare/features/conversations/presentation/screens/chat_detail_screen.dart';

// =============================================================================
// Fake auth notifier — matches pattern from existing tests
// =============================================================================
class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier(super.state);

  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> register({
    required String email,
    String? phoneNumber,
    required String password,
    required String fullName,
  }) async {}
  @override
  Future<void> tryAutoLogin() async {}
}

// =============================================================================
// Fake CommentsRepository — no-op stubs for the fake notifier
// =============================================================================
class _FakeCommentsRepository implements CommentsRepository {
  @override
  Future<PagedResponse<CommentDto>> getComments(
    String listingId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return PagedResponse<CommentDto>(
      items: const [],
      page: page,
      pageSize: pageSize,
      totalItems: 0,
    );
  }

  @override
  Future<CommentDto> createComment(
    String listingId,
    CreateCommentRequest request,
  ) async {
    throw UnimplementedError('not used in tests');
  }

  @override
  Future<CommentDto> updateComment(
    String commentId,
    UpdateCommentRequest request,
  ) async {
    throw UnimplementedError('not used in tests');
  }

  @override
  Future<void> deleteComment(String commentId) async {}
}

// =============================================================================
// Fake ConversationsRepository — no-op stubs
// =============================================================================
class _FakeConversationsRepository implements ConversationsRepository {
  @override
  Future<PagedResponse<ConversationDto>> getMyConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    return PagedResponse<ConversationDto>(
      items: const [],
      page: page,
      pageSize: pageSize,
      totalItems: 0,
    );
  }

  @override
  Future<ConversationDetailDto> createOrOpenConversation(
      String listingId) async {
    throw UnimplementedError('not used in tests');
  }

  @override
  Future<ConversationDetailDto> getConversationDetail(
      String conversationId) async {
    throw UnimplementedError('not used in tests');
  }

  @override
  Future<PagedResponse<MessageDto>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    return PagedResponse<MessageDto>(
      items: const [],
      page: page,
      pageSize: pageSize,
      totalItems: 0,
    );
  }

  @override
  Future<MessageDto> sendMessageHttp(
    String conversationId,
    String content,
  ) async {
    throw UnimplementedError('not used in tests');
  }

  @override
  Future<void> markAsRead(String conversationId) async {}
}

// =============================================================================
// Fake SignalRService — stub for ChatNotifier constructor
// =============================================================================
class _FakeSignalRService implements SignalRService {
  final _messageReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  @override
  bool get isConnected => false;

  @override
  Stream<Map<String, dynamic>> get onMessageReceived =>
      _messageReceivedController.stream;

  @override
  Stream<Map<String, dynamic>> get onNotificationReceived =>
      _notificationReceivedController.stream;

  @override
  Stream<bool> get onConnectionStateChanged =>
      _connectionStateController.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  void dispose() {
    _messageReceivedController.close();
    _notificationReceivedController.close();
    _connectionStateController.close();
  }

  @override
  Future<void> joinConversation(String conversationId) async {}

  @override
  Future<void> leaveConversation(String conversationId) async {}

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {}

  @override
  Future<void> markAsRead({required String conversationId}) async {}
}

// =============================================================================
// Fake CommentsNotifier — on-demand state control
// =============================================================================
class _FakeCommentsNotifier extends CommentsNotifier {
  _FakeCommentsNotifier()
      : super(_FakeCommentsRepository(), 'listing-1');

  @override
  Future<void> loadComments() async {}

  @override
  Future<void> createComment(String content,
      {String? parentCommentId}) async {}

  @override
  Future<void> updateComment(String commentId, String content) async {}

  @override
  Future<void> deleteComment(String commentId) async {}
}

// =============================================================================
// Fake ChatNotifier — on-demand state control
// =============================================================================
class _FakeChatNotifier extends ChatNotifier {
  _FakeChatNotifier()
      : super(
          _FakeConversationsRepository(),
          _FakeSignalRService(),
          'conv-1',
          'owner-1',
        );

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> sendMessage(String content) async {}

  @override
  Future<void> loadMore() async {}

  @override
  void dispose() {}
}

// =============================================================================
// Sample data
// =============================================================================

final _sampleProfile = UserProfileDto(
  id: 'owner-1',
  email: 'owner@example.com',
  fullName: 'Nguyen Van A',
  avatarUrl: null,
  schoolId: 'school-1',
  schoolName: 'Đại học Bách Khoa',
  areaId: 'area-1',
  areaName: 'Quận 10',
  reputationScore: 95.5,
  totalReviews: 12,
  isVerified: true,
);

final _sampleOtherProfile = UserProfileDto(
  id: 'user-2',
  email: 'other@example.com',
  fullName: 'Tran Thi B',
  avatarUrl: null,
  reputationScore: 80.0,
  totalReviews: 5,
  isVerified: false,
);

CommentDto _sampleComment({
  String id = 'comment-1',
  String listingId = 'listing-1',
  String userId = 'owner-1',
  String userName = 'Nguyen Van A',
  String? parentCommentId,
  String content = 'Sách này còn mới không bạn?',
  bool isDeleted = false,
}) {
  return CommentDto(
    id: id,
    listingId: listingId,
    userId: userId,
    userName: userName,
    content: content,
    parentCommentId: parentCommentId,
    createdAt: DateTime(2026, 6, 22, 10, 30),
    isDeleted: isDeleted,
  );
}

ConversationDto _sampleConversation({
  String id = 'conv-1',
  String listingTitle = 'Sách Giải Tích',
  String otherParticipantName = 'Nguyen Van A',
  int unreadCount = 0,
  String? lastMessageContent,
}) {
  return ConversationDto(
    id: id,
    listingId: 'listing-1',
    listingTitle: listingTitle,
    otherParticipantId: 'owner-1',
    otherParticipantName: otherParticipantName,
    lastMessageContent: lastMessageContent,
    lastMessageAt: DateTime(2026, 6, 23, 15, 0),
    unreadCount: unreadCount,
    createdAt: DateTime(2026, 6, 20),
  );
}

ConversationDetailDto _sampleConversationDetail({
  String id = 'conv-1',
  String ownerId = 'owner-1',
  String ownerName = 'Nguyen Van A',
  String requesterId = 'user-2',
  String requesterName = 'Tran Thi B',
}) {
  return ConversationDetailDto(
    id: id,
    listingId: 'listing-1',
    listingTitle: 'Sách Giải Tích',
    ownerId: ownerId,
    ownerName: ownerName,
    requesterId: requesterId,
    requesterName: requesterName,
    createdAt: DateTime(2026, 6, 20),
  );
}

MessageDto _sampleMessage({
  String id = 'msg-1',
  String conversationId = 'conv-1',
  String senderId = 'owner-1',
  String senderName = 'Nguyen Van A',
  String content = 'Chào bạn, sách còn không?',
  String status = 'Sent',
}) {
  return MessageDto(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    senderName: senderName,
    content: content,
    status: status,
    createdAt: DateTime(2026, 6, 23, 15, 5),
  );
}

// =============================================================================
// TESTS
// =============================================================================
void main() {
  // ===========================================================================
  // CommentsScreen Widget Tests (FR-012)
  // ===========================================================================
  group('CommentsScreen', () {
    testWidgets('renders app bar with title "Bình luận"', (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = const CommentsLoading();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Bình luận'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = const CommentsLoading();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Đang tải bình luận...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = const CommentsError('Lỗi kết nối');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Không thể tải bình luận'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Lỗi kết nối'),
        findsOneWidget,
      );
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('shows empty state when no comments', (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(comments: [], totalCount: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có bình luận nào'), findsOneWidget);
      expect(
        find.text('Hãy là người đầu tiên bình luận'),
        findsOneWidget,
      );
    });

    testWidgets('shows comment list with user name and content',
        (tester) async {
      final comment = _sampleComment();
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(
        comments: [comment],
        totalCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(
        find.text('Sách này còn mới không bạn?'),
        findsOneWidget,
      );
    });

    testWidgets('shows reply/edit/delete for own comment as authenticated user',
        (tester) async {
      final comment = _sampleComment();
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(
        comments: [comment],
        totalCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trả lời'), findsOneWidget);
      expect(find.text('Sửa'), findsOneWidget);
      expect(find.text('Xóa'), findsOneWidget);
    });

    testWidgets('shows guest hint text "Đăng nhập để bình luận" in input bar',
        (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(comments: [], totalCount: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đăng nhập để bình luận'), findsOneWidget);
    });

    testWidgets('shows "Viết bình luận..." hint for authenticated users',
        (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(comments: [], totalCount: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Viết bình luận...'), findsOneWidget);
    });

    testWidgets('shows reply input bar when tapping "Trả lời"',
        (tester) async {
      final comment = _sampleComment(userId: 'user-2', userName: 'Tran Thi B');
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(
        comments: [comment],
        totalCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Trả lời"
      await tester.tap(find.text('Trả lời'));
      await tester.pump();

      // Should show reply targeting the user
      expect(find.textContaining('Trả lời Tran Thi B'), findsOneWidget);
      expect(find.text('Viết câu trả lời...'), findsOneWidget);
    });

    testWidgets('shows edit mode when tapping "Sửa"', (tester) async {
      final comment = _sampleComment();
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(
        comments: [comment],
        totalCount: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Sửa"
      await tester.tap(find.text('Sửa'));
      await tester.pump();

      // Should show edit hint
      expect(find.text('Chỉnh sửa bình luận...'), findsOneWidget);
      // Should show save and cancel buttons
      expect(find.text('Lưu'), findsOneWidget);
    });

    testWidgets('shows [đã xóa] for deleted comment without action buttons',
        (tester) async {
      final deletedComment = _sampleComment(isDeleted: true);
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(
        comments: [deletedComment],
        totalCount: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('[đã xóa]'), findsOneWidget);
      // Deleted comments should not show reply/edit/delete actions
      expect(find.text('Trả lời'), findsNothing);
      expect(find.text('Sửa'), findsNothing);
      expect(find.text('Xóa'), findsNothing);
    });

    testWidgets('shows nested replies with threaded display',
        (tester) async {
      final parentComment = _sampleComment(
        id: 'comment-1',
        content: 'Sách này bao nhiêu tiền?',
      );
      final reply = _sampleComment(
        id: 'comment-2',
        parentCommentId: 'comment-1',
        userId: 'user-2',
        userName: 'Tran Thi B',
        content: '10k/ngày bạn nhé',
      );
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(
        comments: [parentComment, reply],
        totalCount: 2,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both comments should be visible
      expect(find.text('Sách này bao nhiêu tiền?'), findsOneWidget);
      expect(find.text('10k/ngày bạn nhé'), findsOneWidget);
      expect(find.text('Tran Thi B'), findsOneWidget);
    });

    testWidgets('send button is present in bottom input bar',
        (tester) async {
      final notifier = _FakeCommentsNotifier();
      notifier.state = CommentsLoaded(comments: [], totalCount: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            commentsProvider('listing-1').overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: CommentsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Send icon button should be present
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });

  // ===========================================================================
  // ConversationListScreen Widget Tests (FR-013)
  // ===========================================================================
  group('ConversationListScreen', () {
    testWidgets('renders app bar with title "Tin nhắn"', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.value(
                PagedResponse<ConversationDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tin nhắn'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 99),
                () => PagedResponse<ConversationDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Đang tải tin nhắn...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance past the delayed future
      await tester.pump(const Duration(seconds: 100));
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.error(Exception('Lỗi mạng')),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Không thể tải tin nhắn'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('shows empty state when no conversations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.value(
                PagedResponse<ConversationDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có tin nhắn nào'), findsOneWidget);
      expect(
        find.text('Hãy bắt đầu trò chuyện từ một bài đăng'),
        findsOneWidget,
      );
    });

    testWidgets('shows conversation list with participant name and listing',
        (tester) async {
      final conv = _sampleConversation(
        lastMessageContent: 'Sách còn không bạn?',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.value(
                PagedResponse<ConversationDto>(
                  items: [conv],
                  page: 1,
                  pageSize: 20,
                  totalItems: 1,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('Sách còn không bạn?'), findsOneWidget);
      expect(find.textContaining('Sách Giải Tích'), findsOneWidget);
    });

    testWidgets('shows unread badge with count', (tester) async {
      final conv = _sampleConversation(unreadCount: 3);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.value(
                PagedResponse<ConversationDto>(
                  items: [conv],
                  page: 1,
                  pageSize: 20,
                  totalItems: 1,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows "về: listingTitle" for listing context',
        (tester) async {
      final conv = _sampleConversation();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.value(
                PagedResponse<ConversationDto>(
                  items: [conv],
                  page: 1,
                  pageSize: 20,
                  totalItems: 1,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('về: Sách Giải Tích'), findsOneWidget);
    });

    testWidgets('shows multiple conversations in list', (tester) async {
      final conv1 = _sampleConversation(
        id: 'conv-1',
        otherParticipantName: 'Nguyen Van A',
      );
      final conv2 = _sampleConversation(
        id: 'conv-2',
        otherParticipantName: 'Tran Thi B',
        listingTitle: 'Máy tính Casio',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
            conversationsProvider(const ConversationListParams())
                .overrideWith(
              (ref) => Future.value(
                PagedResponse<ConversationDto>(
                  items: [conv1, conv2],
                  page: 1,
                  pageSize: 20,
                  totalItems: 2,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ConversationListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('Tran Thi B'), findsOneWidget);
      expect(find.text('về: Máy tính Casio'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ChatDetailScreen Widget Tests (FR-014)
  // ===========================================================================
  group('ChatDetailScreen', () {
    testWidgets('shows login prompt for unauthenticated user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(AuthUnauthenticated()),
            ),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Vui lòng đăng nhập để xem tin nhắn'),
        findsOneWidget,
      );
    });

    testWidgets('shows loading state for authenticated user', (tester) async {
      final notifier = _FakeChatNotifier();
      notifier.state = const ChatLoading();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Đang tải tin nhắn...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      final notifier = _FakeChatNotifier();
      notifier.state = const ChatError('Không thể kết nối');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Không thể tải tin nhắn'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Không thể kết nối'),
        findsOneWidget,
      );
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('shows empty state when no messages', (tester) async {
      final detail = _sampleConversationDetail();
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có tin nhắn'), findsOneWidget);
      expect(
        find.text('Hãy gửi tin nhắn đầu tiên'),
        findsOneWidget,
      );
    });

    testWidgets('shows own message bubble on the right', (tester) async {
      final detail = _sampleConversationDetail();
      final ownMessage = _sampleMessage(
        senderId: 'owner-1',
        senderName: 'Nguyen Van A',
        content: 'Chào bạn, sách còn không?',
      );
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [ownMessage],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chào bạn, sách còn không?'), findsOneWidget);
      // Own message has sent status icon (done, not done_all)
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('shows other participant message bubble on the left',
        (tester) async {
      final detail = _sampleConversationDetail();
      final otherMessage = _sampleMessage(
        id: 'msg-2',
        senderId: 'user-2',
        senderName: 'Tran Thi B',
        content: 'Còn bạn nhé!',
      );
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [otherMessage],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Còn bạn nhé!'), findsOneWidget);
      // Other participant's message should NOT have status icons
      expect(find.byIcon(Icons.done), findsNothing);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('shows read status icon for read messages', (tester) async {
      final detail = _sampleConversationDetail();
      final readMessage = _sampleMessage(
        senderId: 'owner-1',
        content: 'Đã đọc rồi nhé',
        status: 'Read',
      );
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [readMessage],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Read message shows done_all (double-check) icon
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('shows message input bar with hint text', (tester) async {
      final detail = _sampleConversationDetail();
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhập tin nhắn...'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows other participant name in app bar', (tester) async {
      final detail = _sampleConversationDetail(
        ownerId: 'owner-1',
        ownerName: 'Nguyen Van A',
        requesterId: 'user-2',
        requesterName: 'Tran Thi B',
      );
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // As owner-1, the other participant is Tran Thi B (requester)
      expect(find.text('Tran Thi B'), findsOneWidget);
    });

    testWidgets('shows both own and other messages in chat', (tester) async {
      final detail = _sampleConversationDetail();
      final ownMsg = _sampleMessage(
        id: 'msg-1',
        senderId: 'owner-1',
        content: 'Chào bạn',
      );
      final otherMsg = _sampleMessage(
        id: 'msg-2',
        senderId: 'user-2',
        senderName: 'Tran Thi B',
        content: 'Chào bạn!',
      );
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [ownMsg, otherMsg],
        conversation: detail,
        hasMore: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chào bạn'), findsOneWidget);
      expect(find.text('Chào bạn!'), findsOneWidget);
    });

    testWidgets('shows "Xem tin nhắn cũ hơn" when hasMore is true',
        (tester) async {
      final detail = _sampleConversationDetail();
      final msg = _sampleMessage();
      final notifier = _FakeChatNotifier();
      notifier.state = ChatLoaded(
        messages: [msg],
        conversation: detail,
        hasMore: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith(
              (ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: _sampleProfile,
                ),
              ),
            ),
            chatProvider((
              conversationId: 'conv-1',
              currentUserId: 'owner-1',
            )).overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: ChatDetailScreen(conversationId: 'conv-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xem tin nhắn cũ hơn'), findsOneWidget);
    });
  });
}
