import 'package:json_annotation/json_annotation.dart';

part 'create_comment_request.g.dart';

@JsonSerializable()
class CreateCommentRequest {
  final String content;
  final String? parentCommentId;

  const CreateCommentRequest({
    required this.content,
    this.parentCommentId,
  });

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentRequestToJson(this);
}
