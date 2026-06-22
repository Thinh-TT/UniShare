import '../../../core/network/api_response.dart';
import '../../conversations/models/conversation_dto.dart';
import '../../conversations/models/conversation_detail_dto.dart';
import '../../conversations/models/message_dto.dart';
import 'conversations_api.dart';

/// Business logic orchestration for conversations and messages.
class ConversationsRepository {
  final ConversationsApi _conversationsApi;

  ConversationsRepository({required ConversationsApi conversationsApi})
      : _conversationsApi = conversationsApi;

  Future<PagedResponse<ConversationDto>> getMyConversations({
    int page = 1,
    int pageSize = 20,
  }) {
    return _conversationsApi.getMyConversations(
      page: page,
      pageSize: pageSize,
    );
  }

  Future<ConversationDetailDto> createOrOpenConversation(
      String listingId) {
    return _conversationsApi.createOrOpenConversation(listingId);
  }

  Future<ConversationDetailDto> getConversationDetail(
      String conversationId) {
    return _conversationsApi.getConversationDetail(conversationId);
  }

  Future<PagedResponse<MessageDto>> getMessages(
    String conversationId, {
    int page = 1,
    int pageSize = 50,
  }) {
    return _conversationsApi.getMessages(
      conversationId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<MessageDto> sendMessageHttp(
    String conversationId,
    String content,
  ) {
    return _conversationsApi.sendMessageHttp(conversationId, content);
  }

  Future<void> markAsRead(String conversationId) {
    return _conversationsApi.markAsRead(conversationId);
  }
}
