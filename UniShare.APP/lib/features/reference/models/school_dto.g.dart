// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolDto _$SchoolDtoFromJson(Map<String, dynamic> json) => SchoolDto(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
);

Map<String, dynamic> _$SchoolDtoToJson(SchoolDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
};
