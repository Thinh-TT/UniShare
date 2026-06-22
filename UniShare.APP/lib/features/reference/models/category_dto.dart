import 'package:json_annotation/json_annotation.dart';

part 'category_dto.g.dart';

@JsonSerializable()
class CategoryDto {
  final String id;
  final String name;
  final String? slug;
  final String? icon;

  const CategoryDto({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);
}
