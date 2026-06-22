import 'package:json_annotation/json_annotation.dart';
import '../../../core/enums/listing_type.dart';
import '../../../core/enums/listing_status.dart';
import '../../users/models/user_summary_dto.dart';

part 'listing_summary_dto.g.dart';

@JsonSerializable()
class ListingSummaryDto {
  final String id;
  final String title;
  final String? coverImageUrl;
  final ListingType listingType;
  final ListingStatus status;
  final double pricePerDay;
  final double? depositAmount;
  final String? categoryName;
  final String? schoolName;
  final String? areaName;
  final UserSummaryDto? owner;
  final int upvoteCount;
  final int commentCount;
  final DateTime createdAt;

  const ListingSummaryDto({
    required this.id,
    required this.title,
    this.coverImageUrl,
    required this.listingType,
    required this.status,
    required this.pricePerDay,
    this.depositAmount,
    this.categoryName,
    this.schoolName,
    this.areaName,
    this.owner,
    required this.upvoteCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory ListingSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ListingSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ListingSummaryDtoToJson(this);
}
