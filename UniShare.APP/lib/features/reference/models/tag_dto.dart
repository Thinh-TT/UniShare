import 'package:json_annotation/json_annotation.dart';

part 'tag_dto.g.dart';

@JsonSerializable()
class TagDto {
  final String id;
  final String name;
  final String? slug;

  const TagDto({
    required this.id,
    required this.name,
    this.slug,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) =>
      _$TagDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TagDtoToJson(this);
}
