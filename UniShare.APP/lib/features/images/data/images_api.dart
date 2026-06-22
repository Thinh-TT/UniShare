import 'dart:io';
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
  Future<List<ListingImageDto>> getImages(String listingId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.listingImages(listingId),
      fromJsonT: (json) => json,
    );
    // The images endpoint might return data as a map with an items list,
    // or directly as a list. Try both formats.
    final data = response.data;
    if (data != null && data.containsKey('items')) {
      final list = data['items'] as List<dynamic>;
      return list
          .map((e) => ListingImageDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Fallback: might be wrapped differently
    return [];
  }

  /// Upload images for a listing. Returns the updated image list.
  Future<List<ListingImageDto>> uploadImages(
    String listingId,
    List<File> files,
  ) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path),
        ),
      );
    }

    final response = await _apiClient.postMultipart<Map<String, dynamic>>(
      path: ApiEndpoints.listingImages(listingId),
      formData: formData,
      fromJsonT: (json) => json,
    );

    final data = response.data;
    if (data != null && data.containsKey('items')) {
      final list = data['items'] as List<dynamic>;
      return list
          .map((e) => ListingImageDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data != null && data.containsKey('data')) {
      final inner = data['data'];
      if (inner is List) {
        return inner
            .map((e) => ListingImageDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
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
