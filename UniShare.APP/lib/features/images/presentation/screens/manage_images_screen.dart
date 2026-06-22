import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/utils/image_url_resolver.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/images_provider.dart';
import '../../models/listing_image_dto.dart';

class ManageImagesScreen extends ConsumerStatefulWidget {
  const ManageImagesScreen({super.key});

  @override
  ConsumerState<ManageImagesScreen> createState() =>
      _ManageImagesScreenState();
}

class _ManageImagesScreenState extends ConsumerState<ManageImagesScreen> {
  final _picker = ImagePicker();

  String? get _listingId {
    final state = GoRouterState.of(context);
    return state.extra as String?;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final listingId = _listingId;
      if (listingId != null) {
        ref.read(imagesProvider(listingId).notifier).loadImages();
      }
    });
  }

  Future<void> _pickAndUpload() async {
    final listingId = _listingId;
    if (listingId == null) return;

    final picked = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: 5,
    );

    if (picked.isNotEmpty && mounted) {
      final files = <({Uint8List bytes, String filename})>[];
      for (final x in picked) {
        final bytes = await x.readAsBytes();
        files.add((bytes: bytes, filename: x.name));
      }
      final success = await ref
          .read(imagesProvider(listingId).notifier)
          .uploadImages(files);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tải lên ${files.length} ảnh')),
        );
      } else if (mounted) {
        final state = ref.read(imagesProvider(listingId));
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      }
    }
  }

  Future<void> _setCover(String imageId) async {
    final listingId = _listingId;
    if (listingId == null) return;

    final success = await ref
        .read(imagesProvider(listingId).notifier)
        .setCoverImage(imageId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đặt làm ảnh bìa')),
      );
    }
  }

  Future<void> _deleteImage(String imageId) async {
    final listingId = _listingId;
    if (listingId == null) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa ảnh',
      message: 'Bạn có chắc chắn muốn xóa ảnh này?',
      confirmLabel: 'Xóa',
      isDangerous: true,
    );
    if (confirmed == true && mounted) {
      final success = await ref
          .read(imagesProvider(listingId).notifier)
          .deleteImage(imageId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ảnh')),
        );
      }
    }
  }

  void _onDone() {
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingId = _listingId;
    if (listingId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ảnh bài đăng')),
        body: const ErrorState(
          message: 'Không tìm thấy bài đăng. Vui lòng quay lại và thử lại.',
        ),
      );
    }

    final state = ref.watch(imagesProvider(listingId));
    final mediaBaseUrl = ref.watch(appConfigProvider).mediaBaseUrl;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Ảnh bài đăng'),
        actions: [
          TextButton(
            onPressed: _onDone,
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingState(message: 'Đang tải ảnh...')
          : state.errorMessage != null && state.images.isEmpty
              ? ErrorState(
                  message: state.errorMessage!,
                  onRetry: () => ref
                      .read(imagesProvider(listingId).notifier)
                      .loadImages(),
                )
              : state.images.isEmpty
                  ? const EmptyState(
                      icon: Icons.image,
                      title: 'Chưa có ảnh nào',
                      subtitle:
                          'Thêm ảnh để bài đăng của bạn thu hút hơn',
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(imagesProvider(listingId).notifier)
                            .loadImages();
                      },
                      child: Column(
                        children: [
                          if (state.isUploading)
                            const LinearProgressIndicator(
                              color: AppColors.green,
                              backgroundColor: AppColors.greenLight,
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: state.images.length + 1, // +1 for add button
                                itemBuilder: (context, index) {
                                  // Add button
                                  if (index >= state.images.length) {
                                    return InkWell(
                                      onTap: _pickAndUpload,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.neutral200,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.add,
                                            size: 40,
                                            color: AppColors.neutral500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  // Image tile
                                  final image = state.images[index];
                                  return _ImageTile(
                                    image: image,
                                    isUploading: state.isUploading,
                                    mediaBaseUrl: mediaBaseUrl,
                                    onSetCover: () =>
                                        _setCover(image.id),
                                    onDelete: () =>
                                        _deleteImage(image.id),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUpload,
        icon: const Icon(Icons.add_a_photo, color: AppColors.white),
        label: const Text('Thêm ảnh',
            style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.green,
      ),
    );
  }
}

/// Tile widget for a single image in the grid.
class _ImageTile extends StatelessWidget {
  final ListingImageDto image;
  final bool isUploading;
  final String mediaBaseUrl;
  final VoidCallback onSetCover;
  final VoidCallback onDelete;

  const _ImageTile({
    required this.image,
    required this.isUploading,
    required this.mediaBaseUrl,
    required this.onSetCover,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: resolveImageUrl(mediaBaseUrl, image.imageUrl),
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.neutral100,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.green,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.neutral100,
              child: const Icon(
                Icons.broken_image,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ),

        // Cover badge
        if (image.isCover)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Ảnh bìa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Action overlay (tap to show)
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSetCover,
              borderRadius: BorderRadius.circular(12),
              child: Container(),
            ),
          ),
        ),

        // Delete button
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: isUploading ? null : onDelete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
