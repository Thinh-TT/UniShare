// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingDetailDto _$ListingDetailDtoFromJson(Map<String, dynamic> json) =>
    ListingDetailDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      listingType: $enumDecode(_$ListingTypeEnumMap, json['listingType']),
      status: $enumDecode(_$ListingStatusEnumMap, json['status']),
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      conditionNote: json['conditionNote'] as String?,
      category: json['category'] == null
          ? null
          : CategoryDto.fromJson(json['category'] as Map<String, dynamic>),
      school: json['school'] == null
          ? null
          : SchoolDto.fromJson(json['school'] as Map<String, dynamic>),
      area: json['area'] == null
          ? null
          : AreaDto.fromJson(json['area'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ListingImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      owner: json['owner'] == null
          ? null
          : UserSummaryDto.fromJson(json['owner'] as Map<String, dynamic>),
      viewCount: (json['viewCount'] as num).toInt(),
      upvoteCount: (json['upvoteCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ListingDetailDtoToJson(ListingDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'listingType': _$ListingTypeEnumMap[instance.listingType]!,
      'status': _$ListingStatusEnumMap[instance.status]!,
      'pricePerDay': instance.pricePerDay,
      'depositAmount': instance.depositAmount,
      'conditionNote': instance.conditionNote,
      'category': instance.category,
      'school': instance.school,
      'area': instance.area,
      'tags': instance.tags,
      'images': instance.images,
      'owner': instance.owner,
      'viewCount': instance.viewCount,
      'upvoteCount': instance.upvoteCount,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
