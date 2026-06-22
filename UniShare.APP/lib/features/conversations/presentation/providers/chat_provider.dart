import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/signalr_client.dart';
import '../../../../core/network/signalr_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/conversations_api.dart';
import '../../data/conversations_repository.dart';
import '../../models/conversation_detail_dto.dart';
import '../../models/message_dto.dart';

// -- Dependency providers (reuse from conversations_provider or define here) --

final chatConversationsApiProvider = Provider<ConversationsApi>((ref) {
  return ConversationsApi(apiClient: ref.read(apiClientProvider));
});

final chatConversationsRepositoryProvider =
    Provider<ConversationsRepository>((ref) {
  return ConversationsRepository(
    conversationsApi: ref.read(chatConversationsApiProvider),
  );
});

// -- State --

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageDto> messages; // oldest-first for display
  final ConversationDetailDto conversation;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatLoaded({
    required this.messages,
    required this.conversation,
    required this.hasMore,
    this.isLoadingMore = false,
  });
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);
}

// -- Notifier --

class ChatNotifier extends StateNotifier<ChatState> {
  final ConversationsRepository _repository;
  final SignalRService _signalR;
  final String conversationId;
  final String currentUserId;

  StreamSubscription<Map<String, dynamic>>? _messageSub;

  ChatNotifier(
    this._repository,
    this._signalR,
    this.conversationId,
    this.currentUserId,
  ) : super(const ChatInitial());

  /// Load conversation detail + messages, connect SignalR.
  Future<void> loadInitial() async {
    state = const ChatLoading();
    try {
      // Ensure SignalR is connected
      if (!_signalR.isConnected) {
        await _signalR.connect();
      }

      final results = await Future.wait([
        _repository.getConversationDetail(conversationId),
        _repository.getMessages(conversationId, page: 1, pageSize: 50),
      ]);

      final detail = results[0] as ConversationDetailDto;
      final pagedMessages = results[1] as PagedResponse<MessageDto>;

      // Backend returns newest first; reverse for chronological display.
      final messages = pagedMessages.items.reversed.toList();

      state = ChatLoaded(
        messages: messages,
        conversation: detail,
        hasMore: pagedMessages.hasMore,
      );

      // Start listening for real-time messages
      _listenForRealTimeMessages();

      // Mark messages as read (from other participant)
      await _repository.markAsRead(conversationId);

      // Join SignalR conversation group
      await _signalR.joinConversation(conversationId);
    } catch (e) {
      state = ChatError(e.toString());
    }
  }

  void _listenForRealTimeMessages() {
    _messageSub = _signalR.onMessageReceived.listen((data) {
      final message = MessageDto.fromJson(data);
      // Only process messages for this conversation
      if (message.conversationId != conversationId) return;
      if (state is! ChatLoaded) return;

      final loaded = state as ChatLoaded;
      // Avoid duplicates (in case SignalR echoes our own message)
      if (loaded.messages.any((m) => m.id == message.id)) return;

      state = ChatLoaded(
        messages: [...loaded.messages, message],
        conversation: loaded.conversation,
        hasMore: loaded.hasMore,
      );

      // Mark as read when received in real-time
      _repository.markAsRead(conversationId);
    });
  }

  /// Send a message: SignalR first, HTTP fallback.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    final trimmed = content.trim();

    try {
      await _signalR.sendMessage(
        conversationId: conversationId,
        content: trimmed,
      );
      // The signalr MessageReceived event will add it to the list.
      // If the backend doesn't echo back, we'll eventually get it via the stream.
    } catch (_) {
      // SignalR failed — fall back to HTTP
      try {
        final message =
            await _repository.sendMessageHttp(conversationId, trimmed);
        if (state is ChatLoaded) {
          final loaded = state as ChatLoaded;
          // Avoid duplicates
          if (!loaded.messages.any((m) => m.id == message.id)) {
            state = ChatLoaded(
              messages: [...loaded.messages, message],
              conversation: loaded.conversation,
              hasMore: loaded.hasMore,
            );
          }
        }
      } catch (e) {
        // Both SignalR and HTTP failed — caller handles UI feedback
        rethrow;
      }
    }
  }

  /// Load older messages (pagination).
  Future<void> loadMore() async {
    if (state is! ChatLoaded) return;
    final loaded = state as ChatLoaded;
    if (!loaded.hasMore || loaded.isLoadingMore) return;

    state = ChatLoaded(
      messages: loaded.messages,
      conversation: loaded.conversation,
      hasMore: loaded.hasMore,
      isLoadingMore: true,
    );

    try {
      final currentPage =
          (loaded.messages.length / 50).ceil(); // approximate
      final result = await _repository.getMessages(
        conversationId,
        page: currentPage + 1,
        pageSize: 50,
      );

      // Prepend older messages (they come newest-first, reverse first)
      final olderMessages = result.items.reversed.toList();
      state = ChatLoaded(
        messages: [...olderMessages, ...loaded.messages],
        conversation: loaded.conversation,
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = ChatLoaded(
        messages: loaded.messages,
        conversation: loaded.conversation,
        hasMore: loaded.hasMore,
        isLoadingMore: false,
      );
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _signalR.leaveConversation(conversationId);
    super.dispose();
  }
}

// -- Provider --

final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState,
    ({String conversationId, String currentUserId})>(
  (ref, params) {
    return ChatNotifier(
      ref.read(chatConversationsRepositoryProvider),
      ref.read(signalRServiceProvider),
      params.conversationId,
      params.currentUserId,
    );
  },
);
