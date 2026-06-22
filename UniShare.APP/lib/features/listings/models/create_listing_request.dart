import 'package:json_annotation/json_annotation.dart';
import '../../../core/enums/listing_type.dart';

part 'create_listing_request.g.dart';

@JsonSerializable()
class CreateListingRequest {
  final String title;
  final String description;
  final String categoryId;
  final String? schoolId;
  final String? areaId;
  final ListingType listingType;
  final double pricePerDay;
  final double depositAmount;
  final String? conditionNote;
  final List<String>? tags;

  const CreateListingRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    this.schoolId,
    this.areaId,
    required this.listingType,
    required this.pricePerDay,
    required this.depositAmount,
    this.conditionNote,
    this.tags,
  });

  factory CreateListingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateListingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateListingRequestToJson(this);
}
