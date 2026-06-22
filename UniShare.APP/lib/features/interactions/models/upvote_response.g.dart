// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upvote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpvoteResponse _$UpvoteResponseFromJson(Map<String, dynamic> json) =>
    UpvoteResponse(
      listingId: json['listingId'] as String,
      isUpvoted: json['isUpvoted'] as bool,
      upvoteCount: (json['upvoteCount'] as num).toInt(),
    );

Map<String, dynamic> _$UpvoteResponseToJson(UpvoteResponse instance) =>
    <String, dynamic>{
      'listingId': instance.listingId,
      'isUpvoted': instance.isUpvoted,
      'upvoteCount': instance.upvoteCount,
    };
