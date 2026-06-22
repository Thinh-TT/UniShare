import 'package:json_annotation/json_annotation.dart';

part 'unread_count_dto.g.dart';

@JsonSerializable()
class UnreadCountDto {
  final int unreadCount;

  const UnreadCountDto({required this.unreadCount});

  factory UnreadCountDto.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountDtoToJson(this);
}
