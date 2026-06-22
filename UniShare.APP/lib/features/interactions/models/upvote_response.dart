import 'package:json_annotation/json_annotation.dart';

part 'upvote_response.g.dart';

/// Response from PUT/DELETE /listings/{id}/upvote.
@JsonSerializable()
class UpvoteResponse {
  final String listingId;
  final bool isUpvoted;
  final int upvoteCount;

  const UpvoteResponse({
    required this.listingId,
    required this.isUpvoted,
    required this.upvoteCount,
  });

  factory UpvoteResponse.fromJson(Map<String, dynamic> json) =>
      _$UpvoteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpvoteResponseToJson(this);
}
