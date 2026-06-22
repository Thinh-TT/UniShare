// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_listing_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateListingRequest _$UpdateListingRequestFromJson(
  Map<String, dynamic> json,
) => UpdateListingRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  categoryId: json['categoryId'] as String,
  schoolId: json['schoolId'] as String?,
  areaId: json['areaId'] as String?,
  listingType: $enumDecode(_$ListingTypeEnumMap, json['listingType']),
  pricePerDay: (json['pricePerDay'] as num).toDouble(),
  depositAmount: (json['depositAmount'] as num).toDouble(),
  conditionNote: json['conditionNote'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$UpdateListingRequestToJson(
  UpdateListingRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'categoryId': instance.categoryId,
  'schoolId': instance.schoolId,
  'areaId': instance.areaId,
  'listingType': _$ListingTypeEnumMap[instance.listingType]!,
  'pricePerDay': instance.pricePerDay,
  'depositAmount': instance.depositAmount,
  'conditionNote': instance.conditionNote,
  'tags': instance.tags,
};

const _$ListingTypeEnumMap = {
  ListingType.rent: 'Rent',
  ListingType.borrow: 'Borrow',
};
