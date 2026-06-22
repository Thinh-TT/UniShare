import 'package:json_annotation/json_annotation.dart';

part 'school_dto.g.dart';

@JsonSerializable()
class SchoolDto {
  final String id;
  final String name;
  final String? slug;

  const SchoolDto({
    required this.id,
    required this.name,
    this.slug,
  });

  factory SchoolDto.fromJson(Map<String, dynamic> json) =>
      _$SchoolDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolDtoToJson(this);
}
