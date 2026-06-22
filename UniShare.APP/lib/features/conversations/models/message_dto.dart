import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final String id;
  final String senderId;
  final String? senderName;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;

  const MessageDto({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.content,
    required this.sentAt,
    this.readAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
