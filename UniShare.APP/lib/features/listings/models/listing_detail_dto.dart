import 'package:json_annotation/json_annotation.dart';
import '../../../core/enums/listing_type.dart';
import '../../../core/enums/listing_status.dart';
import '../../users/models/user_summary_dto.dart';
import '../../reference/models/category_dto.dart';
import '../../reference/models/school_dto.dart';
import '../../reference/models/area_dto.dart';
import '../../reference/models/tag_dto.dart';
import '../../images/models/listing_image_dto.dart';

part 'listing_detail_dto.g.dart';

@JsonSerializable()
class ListingDetailDto {
  final String id;
  final String title;
  final String description;
  final ListingType listingType;
  final ListingStatus status;
  final double pricePerDay;
  final double? depositAmount;
  final String? conditionNote;
  final CategoryDto? category;
  final SchoolDto? school;
  final AreaDto? area;
  final List<TagDto>? tags;
  final List<ListingImageDto>? images;
  final UserSummaryDto? owner;
  final int viewCount;
  final int upvoteCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ListingDetailDto({
    required this.id,
    required this.title,
    required this.description,
    required this.listingType,
    required this.status,
    required this.pricePerDay,
    this.depositAmount,
    this.conditionNote,
    this.category,
    this.school,
    this.area,
    this.tags,
    this.images,
    this.owner,
    required this.viewCount,
    required this.upvoteCount,
    required this.commentCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory ListingDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ListingDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ListingDetailDtoToJson(this);
}
