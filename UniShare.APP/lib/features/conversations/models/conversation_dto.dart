import 'package:json_annotation/json_annotation.dart';

part 'conversation_dto.g.dart';

/// Matches backend ConversationSummaryDto (used for list endpoint).
@JsonSerializable()
class ConversationDto {
  final String id;
  final String listingId;
  final String listingTitle;
  final String? listingCoverImageUrl;
  final String otherParticipantId;
  final String otherParticipantName;
  final String? otherParticipantAvatarUrl;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  const ConversationDto({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    this.listingCoverImageUrl,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.otherParticipantAvatarUrl,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDtoToJson(this);
}
