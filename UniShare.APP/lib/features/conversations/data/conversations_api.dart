import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../conversations/models/conversation_dto.dart';
import '../../conversations/models/conversation_detail_dto.dart';
import '../../conversations/models/message_dto.dart';
import '../../conversations/models/send_message_request.dart';

/// Low-level API calls for conversations and messages.
class ConversationsApi {
  final ApiClient _apiClient;

  ConversationsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get paged list of the current user's conversations.
  Future<PagedResponse<ConversationDto>> getMyConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _apiClient.getPaged<ConversationDto>(
      path: ApiEndpoints.myConversations,
      queryParams: {'page': page, 'pageSize': pageSize},
      fromJsonT: (json) =>
          ConversationDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Create or get existing conversation for a listing.
  Future<ConversationDetailDto> createOrOpenConversation(
      String listingId) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.conversations(listingId),
    );
    return ConversationDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Get conversation detail (participant only).
  Future<ConversationDetailDto> getConversationDetail(
      String conversationId) async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.conversationById(conversationId),
    );
    return ConversationDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Get paged messages for a conversation (newest first from backend).
  Future<PagedResponse<MessageDto>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    return _apiClient.getPaged<MessageDto>(
      path: ApiEndpoints.messages(conversationId),
      queryParams: {'page': page, 'pageSize': pageSize},
      fromJsonT: (json) => MessageDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Send a message via HTTP (fallback when SignalR is unavailable).
  Future<MessageDto> sendMessageHttp(
    String conversationId,
    String content,
  ) async {
    final response = await _apiClient.post<MessageDto>(
      path: ApiEndpoints.messages(conversationId),
      data: SendMessageRequest(content: content).toJson(),
      fromJsonT: (json) => MessageDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Mark messages in a conversation as read.
  Future<void> markAsRead(String conversationId) async {
    await _apiClient.patch<void>(
      path: ApiEndpoints.markRead(conversationId),
      fromJsonT: (_) => null,
    );
  }
}
