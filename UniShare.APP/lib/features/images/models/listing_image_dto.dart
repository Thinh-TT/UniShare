import 'package:json_annotation/json_annotation.dart';

part 'listing_image_dto.g.dart';

@JsonSerializable()
class ListingImageDto {
  final String id;
  final String imageUrl;
  final bool isCover;
  final int displayOrder;

  const ListingImageDto({
    required this.id,
    required this.imageUrl,
    required this.isCover,
    required this.displayOrder,
  });

  factory ListingImageDto.fromJson(Map<String, dynamic> json) =>
      _$ListingImageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ListingImageDtoToJson(this);
}
