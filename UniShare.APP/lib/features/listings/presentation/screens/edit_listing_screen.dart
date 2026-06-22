import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../core/enums/listing_type.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../reference/presentation/providers/reference_provider.dart';
import '../../../reference/models/category_dto.dart';
import '../../../reference/models/school_dto.dart';
import '../../../reference/models/area_dto.dart';
import '../providers/listings_provider.dart'
    show listingDetailProvider, listingsRepositoryProvider;
import '../providers/listing_form_provider.dart';
import '../../models/listing_detail_dto.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final String listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _conditionController = TextEditingController();
  final _tagController = TextEditingController();

  bool _initialized = false;
  bool _dataLoaded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _conditionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _initListeners() {
    if (_initialized) return;
    _initialized = true;

    _titleController.addListener(() {
      ref.read(listingFormProvider.notifier).setTitle(_titleController.text);
    });
    _descriptionController.addListener(() {
      ref
          .read(listingFormProvider.notifier)
          .setDescription(_descriptionController.text);
    });
    _priceController.addListener(() {
      final price = double.tryParse(_priceController.text) ?? 0;
      ref.read(listingFormProvider.notifier).setPricePerDay(price);
    });
    _depositController.addListener(() {
      final deposit = double.tryParse(_depositController.text) ?? 0;
      ref.read(listingFormProvider.notifier).setDepositAmount(deposit);
    });
    _conditionController.addListener(() {
      ref
          .read(listingFormProvider.notifier)
          .setConditionNote(_conditionController.text);
    });
  }

  void _loadData(ListingDetailDto listing) {
    if (_dataLoaded) return;
    _dataLoaded = true;

    ref.read(listingFormProvider.notifier).loadExistingListing(listing);

    _titleController.text = listing.title;
    _descriptionController.text = listing.description;
    _priceController.text = listing.pricePerDay > 0
        ? listing.pricePerDay.toStringAsFixed(0)
        : '';
    _depositController.text = (listing.depositAmount ?? 0) > 0
        ? listing.depositAmount!.toStringAsFixed(0)
        : '';
    _conditionController.text = listing.conditionNote ?? '';
  }

  Future<void> _showCategoryPicker() async {
    final categoriesAsync = ref.read(categoriesProvider);
    final categories = categoriesAsync.valueOrNull;
    if (categories == null || categories.isEmpty) return;

    final selected = await AppBottomSheet.show<CategoryDto>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn danh mục',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  leading: cat.icon != null
                      ? Text(cat.icon!, style: const TextStyle(fontSize: 20))
                      : null,
                  title: Text(cat.name),
                  onTap: () => Navigator.pop(context, cat),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      ref
          .read(listingFormProvider.notifier)
          .setCategoryId(selected.id, selected.name);
    }
  }

  Future<void> _showSchoolPicker() async {
    final schoolsAsync = ref.read(schoolsProvider);
    final schools = schoolsAsync.valueOrNull;
    if (schools == null || schools.isEmpty) return;

    final selected = await AppBottomSheet.show<SchoolDto>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn trường',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: schools.length,
              itemBuilder: (context, index) {
                final school = schools[index];
                return ListTile(
                  title: Text(school.name),
                  onTap: () => Navigator.pop(context, school),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      ref
          .read(listingFormProvider.notifier)
          .setSchoolId(selected.id, selected.name);
    }
  }

  Future<void> _showAreaPicker() async {
    final areasAsync = ref.read(areasProvider);
    final areas = areasAsync.valueOrNull;
    if (areas == null || areas.isEmpty) return;

    final selected = await AppBottomSheet.show<AreaDto>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chọn khu vực',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: areas.length,
              itemBuilder: (context, index) {
                final area = areas[index];
                return ListTile(
                  title: Text(area.name),
                  onTap: () => Navigator.pop(context, area),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (selected != null && mounted) {
      ref
          .read(listingFormProvider.notifier)
          .setAreaId(selected.id, selected.name);
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      ref.read(listingFormProvider.notifier).addTag(_tagController.text.trim());
      _tagController.clear();
    }
  }

  Future<void> _submit() async {
    final listingId = await ref.read(listingFormProvider.notifier).submit();
    if (listingId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thay đổi')),
      );
      if (mounted) context.pop();
    }
  }

  Future<void> _closeListing() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Đóng bài đăng',
      message:
          'Bạn có chắc chắn muốn đóng bài đăng này?\nBài đăng sẽ không hiển thị trong kết quả tìm kiếm.',
      confirmLabel: 'Đóng',
    );
    if (confirmed == true && mounted) {
      // ignore: unused_label
      try {
        await ref
            .read(listingsRepositoryProvider)
            .closeListing(widget.listingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã đóng bài đăng')),
          );
          context.pop();
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteListing() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa bài đăng',
      message: 'Bạn có chắc chắn muốn xóa bài đăng này?\nHành động này không thể hoàn tác.',
      confirmLabel: 'Xóa',
      isDangerous: true,
    );
    if (confirmed == true && mounted) {
      // ignore: unused_label
      try {
        await ref
            .read(listingsRepositoryProvider)
            .deleteListing(widget.listingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bài đăng')),
          );
          context.pop();
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _navigateToManageImages() {
    context.push('/post/create/images', extra: widget.listingId);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(listingDetailProvider(widget.listingId));
    _initListeners();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Sửa bài đăng'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'close') _closeListing();
              if (value == 'delete') _deleteListing();
              if (value == 'images') _navigateToManageImages();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'images',
                child: ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.green),
                  title: Text('Quản lý ảnh'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'close',
                child: ListTile(
                  leading: Icon(Icons.block, color: AppColors.warning),
                  title: Text('Đóng bài đăng'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.danger),
                  title: Text('Xóa bài đăng'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () =>
            const LoadingState(message: 'Đang tải thông tin bài đăng...'),
        error: (error, _) => ErrorState(
          message: 'Không thể tải bài đăng.\n${error.toString()}',
          onRetry: () =>
              ref.invalidate(listingDetailProvider(widget.listingId)),
        ),
        data: (listing) {
          // Delay provider modification to avoid modifying during build.
          Future.microtask(() => _loadData(listing));
          final formState = ref.watch(listingFormProvider);
          final isBorrow = formState.listingType == ListingType.borrow;

          return Form(
            key: _formKey,
            child: AbsorbPointer(
              absorbing: formState.isSubmitting,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Title
                  AppInput(
                    label: 'Tiêu đề *',
                    hintText: 'Nhập tên đồ dùng',
                    controller: _titleController,
                    maxLines: 1,
                    validator: (_) => formState.titleError,
                  ),
                  const SizedBox(height: 16),

                  // Category picker
                  Text(
                    'Danh mục *',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showCategoryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: formState.categoryError != null
                              ? AppColors.danger
                              : AppColors.neutral200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formState.categoryName ?? 'Chọn danh mục',
                              style: TextStyle(
                                color: formState.categoryName != null
                                    ? AppColors.neutral900
                                    : AppColors.neutral500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.neutral500),
                        ],
                      ),
                    ),
                  ),
                  if (formState.categoryError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        formState.categoryError!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Listing type
                  Text(
                    'Hình thức',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ListingType>(
                    segments: const [
                      ButtonSegment(
                        value: ListingType.rent,
                        label: Text('Cho thuê'),
                        icon: Icon(Icons.attach_money, size: 18),
                      ),
                      ButtonSegment(
                        value: ListingType.borrow,
                        label: Text('Cho mượn'),
                        icon: Icon(Icons.volunteer_activism, size: 18),
                      ),
                    ],
                    selected: {formState.listingType},
                    onSelectionChanged: (selected) {
                      ref
                          .read(listingFormProvider.notifier)
                          .setListingType(selected.first);
                      if (selected.first == ListingType.borrow) {
                        _priceController.text = '0';
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.greenLight;
                        }
                        return AppColors.white;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price per day
                  AppInput(
                    label: isBorrow
                        ? 'Giá/ngày (miễn phí)'
                        : 'Giá/ngày (VNĐ) *',
                    hintText: isBorrow ? '0' : 'Nhập giá cho thuê',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    enabled: !isBorrow,
                  ),
                  const SizedBox(height: 16),

                  // Deposit
                  if (!isBorrow)
                    AppInput(
                      label: 'Tiền cọc (VNĐ)',
                      hintText: 'Nhập số tiền cọc (nếu có)',
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                    ),
                  if (!isBorrow) const SizedBox(height: 16),

                  // Condition note
                  AppInput(
                    label: 'Tình trạng',
                    hintText: 'Mô tả tình trạng đồ dùng',
                    controller: _conditionController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  AppInput(
                    label: 'Mô tả *',
                    hintText: 'Mô tả chi tiết về đồ dùng',
                    controller: _descriptionController,
                    maxLines: 5,
                    validator: (_) => formState.descriptionError,
                  ),
                  const SizedBox(height: 16),

                  // School picker
                  Text(
                    'Trường học',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showSchoolPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formState.schoolName ??
                                  'Chọn trường (tùy chọn)',
                              style: TextStyle(
                                color: formState.schoolName != null
                                    ? AppColors.neutral900
                                    : AppColors.neutral500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.neutral500),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Area picker
                  Text(
                    'Khu vực',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showAreaPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formState.areaName ??
                                  'Chọn khu vực (tùy chọn)',
                              style: TextStyle(
                                color: formState.areaName != null
                                    ? AppColors.neutral900
                                    : AppColors.neutral500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.neutral500),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          label: 'Thẻ tag',
                          hintText: 'Nhập tag và bấm +',
                          controller: _tagController,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.green),
                          onPressed: _addTag,
                        ),
                      ),
                    ],
                  ),
                  if (formState.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: formState.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            ref
                                .read(listingFormProvider.notifier)
                                .removeTag(tag);
                          },
                          backgroundColor: AppColors.greenLight,
                          side: const BorderSide(color: AppColors.green),
                          labelStyle: const TextStyle(
                            color: AppColors.greenDark,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Error message
                  if (formState.errorMessage != null) ...[
                    Text(
                      formState.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Save button
                  AppButton(
                    label: 'Lưu thay đổi',
                    onPressed: _submit,
                    isLoading: formState.isSubmitting,
                  ),
                  const SizedBox(height: 12),

                  // Close / Delete buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Đóng bài đăng',
                          onPressed: _closeListing,
                          variant: AppButtonVariant.secondary,
                          icon: Icons.block,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Xóa bài đăng',
                          onPressed: _deleteListing,
                          variant: AppButtonVariant.danger,
                          icon: Icons.delete,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
