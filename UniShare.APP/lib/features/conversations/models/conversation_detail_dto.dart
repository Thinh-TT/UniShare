import 'package:json_annotation/json_annotation.dart';

part 'conversation_detail_dto.g.dart';

/// Matches backend ConversationDetailDto (used for detail/create endpoints).
/// Unlike ConversationDto (summary), this includes both owner and requester info.
@JsonSerializable()
class ConversationDetailDto {
  final String id;
  final String listingId;
  final String listingTitle;
  final String? listingImageUrl;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final String requesterId;
  final String requesterName;
  final String? requesterAvatarUrl;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const ConversationDetailDto({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    this.listingImageUrl,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatarUrl,
    required this.requesterId,
    required this.requesterName,
    this.requesterAvatarUrl,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ConversationDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationDetailDtoToJson(this);
}
