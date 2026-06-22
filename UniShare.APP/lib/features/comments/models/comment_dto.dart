import 'package:json_annotation/json_annotation.dart';

part 'comment_dto.g.dart';

@JsonSerializable()
class CommentDto {
  final String id;
  final String listingId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String? parentCommentId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Local-only field — backend does not expose isDeleted in the DTO.
  /// Set optimistically after a successful DELETE call.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isDeleted;

  const CommentDto({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    this.parentCommentId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) =>
      _$CommentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CommentDtoToJson(this);

  CommentDto copyWith({
    String? id,
    String? listingId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? parentCommentId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool clearUserAvatarUrl = false,
    bool clearParentCommentId = false,
    bool clearUpdatedAt = false,
  }) {
    return CommentDto(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl:
          clearUserAvatarUrl ? null : (userAvatarUrl ?? this.userAvatarUrl),
      parentCommentId: clearParentCommentId
          ? null
          : (parentCommentId ?? this.parentCommentId),
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
