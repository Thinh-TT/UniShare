import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/conversations_api.dart';
import '../../data/conversations_repository.dart';
import '../../models/conversation_dto.dart';

// -- Dependency providers --

final conversationsApiProvider = Provider<ConversationsApi>((ref) {
  return ConversationsApi(apiClient: ref.read(apiClientProvider));
});

final conversationsRepositoryProvider =
    Provider<ConversationsRepository>((ref) {
  return ConversationsRepository(
    conversationsApi: ref.read(conversationsApiProvider),
  );
});

// -- Params --

class ConversationListParams {
  final int page;
  final int pageSize;

  const ConversationListParams({this.page = 1, this.pageSize = 20});

  ConversationListParams copyWith({int? page, int? pageSize}) {
    return ConversationListParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationListParams &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(page, pageSize);
}

// -- Provider --

final conversationsProvider = FutureProvider.family<
    PagedResponse<ConversationDto>,
    ConversationListParams>((ref, params) async {
  return ref.read(conversationsRepositoryProvider).getMyConversations(
        page: params.page,
        pageSize: params.pageSize,
      );
});
