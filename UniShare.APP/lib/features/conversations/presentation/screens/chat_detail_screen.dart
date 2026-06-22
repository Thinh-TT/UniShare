import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/chat_provider.dart';
import '../../models/message_dto.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadChat());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadChat() {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final params = (
      conversationId: widget.conversationId,
      currentUserId: authState.user.id,
    );
    ref.read(chatProvider(params).notifier).loadInitial();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final params = (
      conversationId: widget.conversationId,
      currentUserId: authState.user.id,
    );

    try {
      await ref.read(chatProvider(params).notifier).sendMessage(content);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi tin nhắn: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays == 1) return 'Hôm qua';
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem tin nhắn')),
      );
    }

    final params = (
      conversationId: widget.conversationId,
      currentUserId: authState.user.id,
    );
    final chatState = ref.watch(chatProvider(params));

    // Determine other participant info
    String? otherName;
    String? otherAvatarUrl;
    if (chatState is ChatLoaded) {
      final conv = chatState.conversation;
      if (conv.ownerId == authState.user.id) {
        otherName = conv.requesterName;
        otherAvatarUrl = conv.requesterAvatarUrl;
      } else {
        otherName = conv.ownerName;
        otherAvatarUrl = conv.ownerAvatarUrl;
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: otherName != null
              ? Row(
                  children: [
                    UserAvatar(
                      avatarUrl: otherAvatarUrl,
                      fullName: otherName,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        otherName,
                        style:
                            Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const Text('Chat'),
        ),
        body: chatState is ChatLoaded
            ? Column(
                children: [
                  // Messages list
                  Expanded(
                    child: chatState.messages.isEmpty
                        ? const EmptyState(
                            icon: Icons.message_outlined,
                            title: 'Chưa có tin nhắn',
                            subtitle:
                                'Hãy gửi tin nhắn đầu tiên',
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8),
                            itemCount: chatState.messages.length +
                                (chatState.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              // "Load more" indicator at top
                              if (chatState.hasMore && index == 0) {
                                return Center(
                                  child: TextButton(
                                    onPressed: () => ref
                                        .read(chatProvider(params)
                                            .notifier)
                                        .loadMore(),
                                    child: chatState.isLoadingMore
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Xem tin nhắn cũ hơn'),
                                  ),
                                );
                              }

                              final msgIndex =
                                  chatState.hasMore ? index - 1 : index;
                              final message = chatState
                                  .messages[msgIndex];
                              final isOwn = message.senderId ==
                                  authState.user.id;

                              return _MessageBubble(
                                message: message,
                                isOwn: isOwn,
                                formatTime: _formatTime,
                              );
                            },
                          ),
                  ),

                  // Message input bar
                  _MessageInputBar(
                    controller: _messageController,
                    isSending: _isSending,
                    onSend: _sendMessage,
                  ),
                ],
              )
            : chatState is ChatLoading
                ? const LoadingState(
                    message: 'Đang tải tin nhắn...')
                : chatState is ChatError
                    ? ErrorState(
                        message: 'Không thể tải tin nhắn.\n'
                            '${(chatState as ChatError).message}',
                        onRetry: _loadChat,
                      )
                    : const SizedBox.shrink(),
      ),
    );
  }
}

/// Single message bubble.
class _MessageBubble extends StatelessWidget {
  final MessageDto message;
  final bool isOwn;
  final String Function(DateTime) formatTime;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isOwn ? AppColors.green : AppColors.neutral100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isOwn
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isOwn
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isOwn ? Colors.white : AppColors.neutral900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isOwn ? Colors.white70 : AppColors.neutral500,
                  ),
                ),
                if (isOwn) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'Read'
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color: message.status == 'Read'
                        ? AppColors.info
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom input bar for chat.
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final canSend = controller.text.trim().isNotEmpty && !isSending;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isSending,
                  onChanged: (_) => (context as Element).markNeedsBuild(),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: AppColors.neutral100,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: canSend ? (_) => onSend() : null,
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor:
                    canSend ? AppColors.green : AppColors.disabled,
                radius: 20,
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white, size: 18),
                        onPressed: canSend ? onSend : null,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
