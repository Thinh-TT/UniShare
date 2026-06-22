// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingSummaryDto _$ListingSummaryDtoFromJson(Map<String, dynamic> json) =>
    ListingSummaryDto(
      id: json['id'] as String,
      title: json['title'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      listingType: $enumDecode(_$ListingTypeEnumMap, json['listingType']),
      status: $enumDecode(_$ListingStatusEnumMap, json['status']),
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      categoryName: json['categoryName'] as String?,
      schoolName: json['schoolName'] as String?,
      areaName: json['areaName'] as String?,
      owner: json['owner'] == null
          ? null
          : UserSummaryDto.fromJson(json['owner'] as Map<String, dynamic>),
      upvoteCount: (json['upvoteCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ListingSummaryDtoToJson(ListingSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'coverImageUrl': instance.coverImageUrl,
      'listingType': _$ListingTypeEnumMap[instance.listingType]!,
      'status': _$ListingStatusEnumMap[instance.status]!,
      'pricePerDay': instance.pricePerDay,
      'depositAmount': instance.depositAmount,
      'categoryName': instance.categoryName,
      'schoolName': instance.schoolName,
      'areaName': instance.areaName,
      'owner': instance.owner,
      'upvoteCount': instance.upvoteCount,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ListingTypeEnumMap = {
  ListingType.rent: 'Rent',
  ListingType.borrow: 'Borrow',
};

const _$ListingStatusEnumMap = {
  ListingStatus.available: 'Available',
  ListingStatus.reserved: 'Reserved',
  ListingStatus.inUse: 'InUse',
  ListingStatus.closed: 'Closed',
};
