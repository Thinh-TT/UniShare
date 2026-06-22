// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationDetailDto _$ConversationDetailDtoFromJson(
  Map<String, dynamic> json,
) => ConversationDetailDto(
  id: json['id'] as String,
  listingId: json['listingId'] as String,
  listingTitle: json['listingTitle'] as String,
  listingImageUrl: json['listingImageUrl'] as String?,
  ownerId: json['ownerId'] as String,
  ownerName: json['ownerName'] as String,
  ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
  requesterId: json['requesterId'] as String,
  requesterName: json['requesterName'] as String,
  requesterAvatarUrl: json['requesterAvatarUrl'] as String?,
  lastMessageContent: json['lastMessageContent'] as String?,
  lastMessageSenderId: json['lastMessageSenderId'] as String?,
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ConversationDetailDtoToJson(
  ConversationDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'listingId': instance.listingId,
  'listingTitle': instance.listingTitle,
  'listingImageUrl': instance.listingImageUrl,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'ownerAvatarUrl': instance.ownerAvatarUrl,
  'requesterId': instance.requesterId,
  'requesterName': instance.requesterName,
  'requesterAvatarUrl': instance.requesterAvatarUrl,
  'lastMessageContent': instance.lastMessageContent,
  'lastMessageSenderId': instance.lastMessageSenderId,
  'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
