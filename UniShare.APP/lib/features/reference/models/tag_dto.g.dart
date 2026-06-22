// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagDto _$TagDtoFromJson(Map<String, dynamic> json) => TagDto(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
);

Map<String, dynamic> _$TagDtoToJson(TagDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
};
