import 'package:json_annotation/json_annotation.dart';

part 'image_order_request.g.dart';

@JsonSerializable()
class ImageOrderItem {
  final String imageId;
  final int displayOrder;

  const ImageOrderItem({
    required this.imageId,
    required this.displayOrder,
  });

  factory ImageOrderItem.fromJson(Map<String, dynamic> json) =>
      _$ImageOrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$ImageOrderItemToJson(this);
}

@JsonSerializable()
class ImageOrderRequest {
  final List<ImageOrderItem> imageOrders;

  const ImageOrderRequest({required this.imageOrders});

  factory ImageOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImageOrderRequestToJson(this);
}
