// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageOrderItem _$ImageOrderItemFromJson(Map<String, dynamic> json) =>
    ImageOrderItem(
      imageId: json['imageId'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
    );

Map<String, dynamic> _$ImageOrderItemToJson(ImageOrderItem instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'displayOrder': instance.displayOrder,
    };

ImageOrderRequest _$ImageOrderRequestFromJson(Map<String, dynamic> json) =>
    ImageOrderRequest(
      imageOrders: (json['imageOrders'] as List<dynamic>)
          .map((e) => ImageOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ImageOrderRequestToJson(ImageOrderRequest instance) =>
    <String, dynamic>{'imageOrders': instance.imageOrders};
