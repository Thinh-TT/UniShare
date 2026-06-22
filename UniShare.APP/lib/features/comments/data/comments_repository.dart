import '../../../core/network/api_response.dart';
import '../../comments/models/comment_dto.dart';
import '../../comments/models/create_comment_request.dart';
import '../../comments/models/update_comment_request.dart';
import 'comments_api.dart';

/// Business logic orchestration for comments.
class CommentsRepository {
  final CommentsApi _commentsApi;

  CommentsRepository({required CommentsApi commentsApi})
      : _commentsApi = commentsApi;

  Future<PagedResponse<CommentDto>> getComments(
    String listingId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return _commentsApi.getComments(listingId, page: page, pageSize: pageSize);
  }

  Future<CommentDto> createComment(
    String listingId,
    CreateCommentRequest request,
  ) {
    return _commentsApi.createComment(listingId, request);
  }

  Future<CommentDto> updateComment(
    String commentId,
    UpdateCommentRequest request,
  ) {
    return _commentsApi.updateComment(commentId, request);
  }

  Future<void> deleteComment(String commentId) {
    return _commentsApi.deleteComment(commentId);
  }
}
