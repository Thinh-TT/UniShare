import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../providers/conversations_provider.dart';
import '../../models/conversation_dto.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(
      conversationsProvider(const ConversationListParams()),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Tin nhắn'),
      ),
      body: conversationsAsync.when(
        loading: () =>
            const LoadingState(message: 'Đang tải tin nhắn...'),
        error: (error, _) => ErrorState(
          message: 'Không thể tải tin nhắn.\n${error.toString()}',
          onRetry: () => ref.invalidate(
            conversationsProvider(const ConversationListParams()),
          ),
        ),
        data: (paged) {
          final conversations = paged.items;

          if (conversations.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_outlined,
              title: 'Chưa có tin nhắn nào',
              subtitle: 'Hãy bắt đầu trò chuyện từ một bài đăng',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                conversationsProvider(const ConversationListParams()),
              );
              await ref.read(
                conversationsProvider(const ConversationListParams()).future,
              );
            },
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return _ConversationCard(
                  conversation: conversations[index],
                  onTap: () {
                    context.push('/chat/${conversations[index].id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// A single conversation row in the list.
class _ConversationCard extends StatelessWidget {
  final ConversationDto conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            UserAvatar(
              avatarUrl: conversation.otherParticipantAvatarUrl,
              fullName: conversation.otherParticipantName,
              size: 48,
            ),
            const SizedBox(width: 12),

            // Middle: name + last message + listing context
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherParticipantName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatRelativeTime(
                              conversation.lastMessageAt!),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: hasUnread
                                    ? AppColors.green
                                    : AppColors.neutral500,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversation.lastMessageContent ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: hasUnread
                              ? AppColors.neutral900
                              : AppColors.neutral500,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'về: ${conversation.listingTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppColors.green,
                        ),
                  ),
                ],
              ),
            ),

            // Unread badge
            if (hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
