import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

/// Matches backend MessageDto.
@JsonSerializable()
class MessageDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final String status; // "Sent", "Read", "Deleted"
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.status,
    this.readAt,
    required this.createdAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
