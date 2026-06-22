import 'package:json_annotation/json_annotation.dart';

part 'area_dto.g.dart';

@JsonSerializable()
class AreaDto {
  final String id;
  final String name;
  final String? city;

  const AreaDto({
    required this.id,
    required this.name,
    this.city,
  });

  factory AreaDto.fromJson(Map<String, dynamic> json) =>
      _$AreaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AreaDtoToJson(this);
}
