import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/images_api.dart';
import '../../models/listing_image_dto.dart';
import '../../models/image_order_request.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;

/// Provider for ImagesApi singleton.
final imagesApiProvider = Provider<ImagesApi>((ref) {
  return ImagesApi(apiClient: ref.read(apiClientProvider));
});

/// State for the Manage Images screen.
class ImagesState {
  final List<ListingImageDto> images;
  final bool isLoading;
  final bool isUploading;
  final String? errorMessage;

  const ImagesState({
    this.images = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.errorMessage,
  });

  ImagesState copyWith({
    List<ListingImageDto>? images,
    bool? isLoading,
    bool? isUploading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ImagesState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for the Manage Images screen.
class ImagesNotifier extends StateNotifier<ImagesState> {
  final ImagesApi _imagesApi;
  final String listingId;

  ImagesNotifier(this._imagesApi, this.listingId)
      : super(const ImagesState());

  /// Load all images for the listing.
  Future<void> loadImages() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    // ignore: unused_label
    try {
      final images = await _imagesApi.getImages(listingId);
      state = state.copyWith(images: images, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải ảnh. ${e.toString()}',
      );
    }
  }

  /// Upload new images.
  Future<bool> uploadImages(List<({Uint8List bytes, String filename})> files) async {
    if (files.isEmpty) return false;

    state = state.copyWith(isUploading: true, clearErrorMessage: true);

    // ignore: unused_label
    try {
      final newImages = await _imagesApi.uploadImages(listingId, files);
      state = state.copyWith(
        images: [...state.images, ...newImages],
        isUploading: false,
      );
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Không thể tải ảnh lên. ${e.toString()}',
      );
      return false;
    }
  }

  /// Set an image as the cover.
  Future<bool> setCoverImage(String imageId) async {
    // ignore: unused_label
    try {
      await _imagesApi.setCoverImage(listingId, imageId);
      // Update local state: the selected becomes cover, others not
      state = state.copyWith(
        images: state.images.map((img) {
          return ListingImageDto(
            id: img.id,
            imageUrl: img.imageUrl,
            isCover: img.id == imageId,
            displayOrder: img.displayOrder,
          );
        }).toList(),
      );
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể đặt ảnh bìa. ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete an image.
  Future<bool> deleteImage(String imageId) async {
    // ignore: unused_label
    try {
      await _imagesApi.deleteImage(listingId, imageId);
      state = state.copyWith(
        images: state.images.where((img) => img.id != imageId).toList(),
      );
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể xóa ảnh. ${e.toString()}',
      );
      return false;
    }
  }

  /// Reorder images (move from oldIndex to newIndex in the list).
  Future<void> reorderImages(int oldIndex, int newIndex) async {
    final reordered = List<ListingImageDto>.from(state.images);
    final item = reordered.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    reordered.insert(insertIndex, item);

    // Optimistic update
    state = state.copyWith(images: reordered);

    // Build order list
    final orderItems = <ImageOrderItem>[];
    for (var i = 0; i < reordered.length; i++) {
      orderItems.add(
        ImageOrderItem(imageId: reordered[i].id, displayOrder: i),
      );
    }

    // ignore: unused_label
    try {
      await _imagesApi.reorderImages(listingId, orderItems);
    } on Exception catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể sắp xếp lại ảnh. ${e.toString()}',
      );
      // Reload to get correct order
      await loadImages();
    }
  }
}

/// Provider for the Manage Images screen (family by listingId).
final imagesProvider = StateNotifierProvider.family<ImagesNotifier, ImagesState,
    String>((ref, listingId) {
  return ImagesNotifier(ref.read(imagesApiProvider), listingId);
});
