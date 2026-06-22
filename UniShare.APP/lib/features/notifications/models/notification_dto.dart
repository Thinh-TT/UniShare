import 'package:json_annotation/json_annotation.dart';
import '../../../core/enums/notification_type.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class NotificationDto {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);
}
