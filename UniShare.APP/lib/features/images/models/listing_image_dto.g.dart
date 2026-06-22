// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingImageDto _$ListingImageDtoFromJson(Map<String, dynamic> json) =>
    ListingImageDto(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      isCover: json['isCover'] as bool,
      displayOrder: (json['displayOrder'] as num).toInt(),
    );

Map<String, dynamic> _$ListingImageDtoToJson(ListingImageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'isCover': instance.isCover,
      'displayOrder': instance.displayOrder,
    };
