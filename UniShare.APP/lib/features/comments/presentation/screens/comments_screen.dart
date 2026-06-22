import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/login_required_modal.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../listings/presentation/providers/listings_provider.dart'
    show listingDetailProvider;
import '../providers/comments_provider.dart';
import '../../models/comment_dto.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String listingId;

  const CommentsScreen({super.key, required this.listingId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _commentController = TextEditingController();
  String? _replyingToId;
  String? _replyingToUserName;
  String? _editingCommentId;
  final _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(commentsProvider(widget.listingId).notifier).loadComments();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) {
      LoginRequiredModal.show(context);
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await ref.read(commentsProvider(widget.listingId).notifier).createComment(
            content,
            parentCommentId: _replyingToId,
          );
      _commentController.clear();
      setState(() {
        _replyingToId = null;
        _replyingToUserName = null;
      });
      // Invalidate listing detail to update comment count
      ref.invalidate(listingDetailProvider(widget.listingId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi bình luận: $e')),
        );
      }
    }
  }

  Future<void> _saveEdit(String commentId) async {
    final content = _editController.text.trim();
    if (content.isEmpty) return;

    try {
      await ref
          .read(commentsProvider(widget.listingId).notifier)
          .updateComment(commentId, content);
      setState(() {
        _editingCommentId = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa bình luận',
      message: 'Bạn có chắc muốn xóa bình luận này?',
      confirmLabel: 'Xóa',
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(commentsProvider(widget.listingId).notifier)
          .deleteComment(commentId);
      ref.invalidate(listingDetailProvider(widget.listingId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa: $e')),
        );
      }
    }
  }

  void _startReply(String commentId, String userName) {
    setState(() {
      _replyingToId = commentId;
      _replyingToUserName = userName;
      _editingCommentId = null;
    });
    _commentController.clear();
    FocusScope.of(context).requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToUserName = null;
    });
    _commentController.clear();
  }

  void _startEdit(CommentDto comment) {
    setState(() {
      _editingCommentId = comment.id;
      _replyingToId = null;
      _replyingToUserName = null;
    });
    _editController.text = comment.content;
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
    });
    _editController.clear();
  }

  /// Build a reply tree from flat list.
  /// Top-level comments have parentCommentId == null.
  List<Widget> _buildCommentTree(
    List<CommentDto> comments,
    String currentUserId,
  ) {
    final topLevel = comments
        .where((c) => c.parentCommentId == null)
        .toList();

    // Group replies by parentCommentId
    final repliesMap = <String, List<CommentDto>>{};
    for (final c in comments) {
      if (c.parentCommentId != null) {
        repliesMap.putIfAbsent(c.parentCommentId!, () => []).add(c);
      }
    }

    final widgets = <Widget>[];
    for (final comment in topLevel) {
      widgets.add(_buildCommentTile(
        comment: comment,
        currentUserId: currentUserId,
        depth: 0,
        repliesMap: repliesMap,
      ));
    }
    return widgets;
  }

  Widget _buildCommentTile({
    required CommentDto comment,
    required String currentUserId,
    required int depth,
    required Map<String, List<CommentDto>> repliesMap,
  }) {
    final isOwn = currentUserId == comment.userId;
    final isEditing = _editingCommentId == comment.id;
    final replies = repliesMap[comment.id] ?? [];
    final isDeleted = comment.isDeleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16.0 + depth * 24.0,
            right: 16,
            top: 8,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    avatarUrl: comment.userAvatarUrl,
                    fullName: comment.userName,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                comment.userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            Text(
                              _formatTime(comment.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.neutral500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isEditing)
                          // Inline edit mode
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _editController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'Chỉnh sửa bình luận...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        _saveEdit(comment.id),
                                    child: const Text('Lưu'),
                                  ),
                                  TextButton(
                                    onPressed: _cancelEdit,
                                    child: Text(
                                      'Hủy',
                                      style: TextStyle(
                                        color: AppColors.neutral500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          // Comment content
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDeleted
                                    ? '[đã xóa]'
                                    : comment.content,
                                style: isDeleted
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.neutral500,
                                          fontStyle: FontStyle.italic,
                                        )
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                              ),
                              if (!isDeleted) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _ActionText(
                                      label: 'Trả lời',
                                      onTap: () => _startReply(
                                        comment.id,
                                        comment.userName,
                                      ),
                                    ),
                                      if (isOwn) ...[
                                        const SizedBox(width: 12),
                                        _ActionText(
                                          label: 'Sửa',
                                          onTap: () =>
                                              _startEdit(comment),
                                        ),
                                        const SizedBox(width: 12),
                                        _ActionText(
                                          label: 'Xóa',
                                          onTap: () => _deleteComment(
                                              comment.id),
                                          color: AppColors.danger,
                                        ),
                                      ],
                                  ],
                                ),
                              ],
                              // Inline reply input
                              if (_replyingToId == comment.id)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8),
                                  child: _ReplyInputBar(
                                    replyingToName:
                                        _replyingToUserName ?? '',
                                    controller: _commentController,
                                    onSend: _sendComment,
                                    onCancel: _cancelReply,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Render child replies
        for (final reply in replies)
          _buildCommentTile(
            comment: reply,
            currentUserId: currentUserId,
            depth: depth + 1,
            repliesMap: repliesMap,
          ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
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
    final authState = ref.watch(authProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;
    final isGuest = authState is! AuthAuthenticated;
    final state = ref.watch(commentsProvider(widget.listingId));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title: const Text('Bình luận'),
        ),
        body: Column(
          children: [
            // Comment list
            Expanded(
              child: state is CommentsLoaded
                  ? (state.comments.isEmpty
                      ? const EmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: 'Chưa có bình luận nào',
                          subtitle: 'Hãy là người đầu tiên bình luận',
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(commentsProvider(widget.listingId)
                                    .notifier)
                                .loadComments();
                          },
                          child: ListView(
                            children: _buildCommentTree(
                              state.comments,
                              currentUserId ?? '',
                            ),
                          ),
                        ))
                  : state is CommentsLoading
                      ? const LoadingState(
                          message: 'Đang tải bình luận...')
                      : state is CommentsError
                          ? ErrorState(
                              message: 'Không thể tải bình luận.\n'
                                  '${(state as CommentsError).message}',
                              onRetry: () => ref
                                  .read(commentsProvider(
                                          widget.listingId)
                                      .notifier)
                                  .loadComments(),
                            )
                          : const SizedBox.shrink(),
            ),

            // Bottom input bar
            if (_replyingToId == null && _editingCommentId == null)
              _BottomInputBar(
                controller: _commentController,
                onSend: _sendComment,
                isGuest: isGuest,
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom comment input bar.
class _BottomInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isGuest;

  const _BottomInputBar({
    required this.controller,
    required this.onSend,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
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
                  enabled: !isGuest,
                  decoration: InputDecoration(
                    hintText: isGuest
                        ? 'Đăng nhập để bình luận'
                        : 'Viết bình luận...',
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
                  onSubmitted: (_) => isGuest ? _showLogin(context) : onSend(),
                  onTap: () {
                    if (isGuest) _showLogin(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.green,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: isGuest ? () => _showLogin(context) : onSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogin(BuildContext context) {
    LoginRequiredModal.show(context);
  }
}

/// Inline reply input shown below the comment being replied to.
class _ReplyInputBar extends StatelessWidget {
  final String replyingToName;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _ReplyInputBar({
    required this.replyingToName,
    required this.controller,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Trả lời $replyingToName',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onCancel,
                child: const Icon(Icons.close, size: 18, color: AppColors.neutral500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Viết câu trả lời...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onSend,
                child: const Text('Gửi'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small text action button (Reply, Edit, Delete).
class _ActionText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionText({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? AppColors.green,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
