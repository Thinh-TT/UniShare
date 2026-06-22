import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/listing_image_dto.dart';
import '../models/image_order_request.dart';

/// Low-level API calls for listing image management.
class ImagesApi {
  final ApiClient _apiClient;

  ImagesApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all images for a listing.
  ///
  /// There is no dedicated GET endpoint for images on the backend.
  /// Images are included in the listing detail response, so we fetch the
  /// listing and extract the images list.
  Future<List<ListingImageDto>> getImages(String listingId) async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.listingById(listingId),
    );
    final data = response['data'] as Map<String, dynamic>;
    final images = (data['images'] as List<dynamic>?)
            ?.map(
                (e) => ListingImageDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return images;
  }

  /// Upload images for a listing.
  ///
  /// Backend returns ApiResponse<List<ListingImageDto>> where the `data`
  /// field is a JSON array (not a map). We use postMultipartRaw to get the
  /// raw wrapper map and extract the list from `data`.
  Future<List<ListingImageDto>> uploadImages(
    String listingId,
    List<({Uint8List bytes, String filename})> files,
  ) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files',
          MultipartFile.fromBytes(file.bytes, filename: file.filename),
        ),
      );
    }

    final response = await _apiClient.postMultipartRaw(
      path: ApiEndpoints.listingImages(listingId),
      formData: formData,
    );

    // Backend returns: {"data": [...images...], "message": "..."}
    final dataList = response['data'] as List<dynamic>?;
    if (dataList != null) {
      return dataList
          .map((e) => ListingImageDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Set an image as the cover image for a listing.
  Future<void> setCoverImage(String listingId, String imageId) async {
    await _apiClient.patch<void>(
      path: ApiEndpoints.coverImage(listingId, imageId),
      fromJsonT: (_) => null,
    );
  }

  /// Reorder images for a listing.
  Future<void> reorderImages(
    String listingId,
    List<ImageOrderItem> order,
  ) async {
    await _apiClient.putRaw(
      path: ApiEndpoints.imageOrder(listingId),
      data: ImageOrderRequest(imageOrders: order).toJson(),
    );
  }

  /// Delete an image from a listing.
  Future<void> deleteImage(String listingId, String imageId) async {
    await _apiClient.delete(
      path: ApiEndpoints.deleteImage(listingId, imageId),
    );
  }
}
