import 'package:json_annotation/json_annotation.dart';
import '../../users/models/user_summary_dto.dart';

part 'comment_dto.g.dart';

@JsonSerializable()
class CommentDto {
  final String id;
  final String content;
  final UserSummaryDto? author;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommentDto({
    required this.id,
    required this.content,
    this.author,
    this.parentCommentId,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentDtoToJson(this);
}
