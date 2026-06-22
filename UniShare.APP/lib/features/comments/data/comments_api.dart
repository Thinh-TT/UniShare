import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../comments/models/comment_dto.dart';
import '../../comments/models/create_comment_request.dart';
import '../../comments/models/update_comment_request.dart';

/// Low-level API calls for comments.
class CommentsApi {
  final ApiClient _apiClient;

  CommentsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get paged comments for a listing (newest first from backend).
  Future<PagedResponse<CommentDto>> getComments(
    String listingId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return _apiClient.getPaged<CommentDto>(
      path: ApiEndpoints.comments(listingId),
      queryParams: {'page': page, 'pageSize': pageSize},
      fromJsonT: (json) => CommentDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Create a new comment (or reply).
  Future<CommentDto> createComment(
    String listingId,
    CreateCommentRequest request,
  ) async {
    final response = await _apiClient.post<CommentDto>(
      path: ApiEndpoints.comments(listingId),
      data: request.toJson(),
      fromJsonT: (json) => CommentDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Update an existing comment (owner only).
  Future<CommentDto> updateComment(
    String commentId,
    UpdateCommentRequest request,
  ) async {
    final response = await _apiClient.put<CommentDto>(
      path: ApiEndpoints.commentById(commentId),
      data: request.toJson(),
      fromJsonT: (json) => CommentDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Soft-delete a comment (owner or admin).
  Future<void> deleteComment(String commentId) async {
    await _apiClient.delete(path: ApiEndpoints.commentById(commentId));
  }
}
