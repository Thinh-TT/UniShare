import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/comments_api.dart';
import '../../data/comments_repository.dart';
import '../../models/comment_dto.dart';
import '../../models/create_comment_request.dart';
import '../../models/update_comment_request.dart';

// -- Dependency providers --

final commentsApiProvider = Provider<CommentsApi>((ref) {
  return CommentsApi(apiClient: ref.read(apiClientProvider));
});

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepository(commentsApi: ref.read(commentsApiProvider));
});

// -- State --

sealed class CommentsState {
  const CommentsState();
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  final List<CommentDto> comments;
  final int totalCount;

  const CommentsLoaded({
    required this.comments,
    required this.totalCount,
  });
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);
}

// -- Notifier --

class CommentsNotifier extends StateNotifier<CommentsState> {
  final CommentsRepository _repository;
  final String listingId;

  CommentsNotifier(this._repository, this.listingId)
      : super(const CommentsInitial());

  Future<void> loadComments() async {
    state = const CommentsLoading();
    try {
      final result =
          await _repository.getComments(listingId, page: 1, pageSize: 50);
      // Backend returns newest first; reverse for chronological display.
      final sorted = result.items.reversed.toList();
      state = CommentsLoaded(
        comments: sorted,
        totalCount: result.totalItems,
      );
    } catch (e) {
      state = CommentsError(e.toString());
    }
  }

  Future<void> createComment(String content,
      {String? parentCommentId}) async {
    if (content.trim().isEmpty) return;
    try {
      await _repository.createComment(
        listingId,
        CreateCommentRequest(
          content: content.trim(),
          parentCommentId: parentCommentId,
        ),
      );
      await loadComments(); // Pessimistic reload
    } catch (e) {
      // Keep current state on error — caller shows SnackBar
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    if (content.trim().isEmpty) return;
    try {
      await _repository.updateComment(
        commentId,
        UpdateCommentRequest(content: content.trim()),
      );
      await loadComments(); // Pessimistic reload
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Soft-delete with optimistic local update.
  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(commentId);
      // Optimistic: mark as deleted in existing state
      if (state is CommentsLoaded) {
        final loaded = state as CommentsLoaded;
        state = CommentsLoaded(
          comments: loaded.comments.map((c) {
            if (c.id == commentId) {
              return c.copyWith(isDeleted: true, content: '[đã xóa]');
            }
            return c;
          }).toList(),
          totalCount: loaded.totalCount - 1,
        );
      }
    } catch (e) {
      // Keep current state on error
    }
  }
}

// -- Provider --

final commentsProvider = StateNotifierProvider.family<CommentsNotifier,
    CommentsState, String>((ref, listingId) {
  return CommentsNotifier(
    ref.read(commentsRepositoryProvider),
    listingId,
  );
});
