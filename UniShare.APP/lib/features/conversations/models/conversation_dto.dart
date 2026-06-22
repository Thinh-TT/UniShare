import 'package:json_annotation/json_annotation.dart';
import '../../users/models/user_summary_dto.dart';

part 'conversation_dto.g.dart';

@JsonSerializable()
class ConversationDto {
  final String id;
  final String listingId;
  final String? listingTitle;
  final UserSummaryDto owner;
  final UserSummaryDto requester;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  const ConversationDto({
    required this.id,
    required this.listingId,
    this.listingTitle,
    required this.owner,
    required this.requester,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDtoToJson(this);
}
