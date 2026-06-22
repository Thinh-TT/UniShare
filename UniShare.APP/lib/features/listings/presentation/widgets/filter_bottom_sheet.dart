import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../reference/presentation/providers/reference_provider.dart';
import '../../presentation/providers/listings_provider.dart';

/// Filter bottom sheet for search/home screens.
///
/// Usage:
/// ```dart
/// final result = await FilterBottomSheet.show(
///   context,
///   currentFilters: myFilters,
/// );
/// if (result != null) { ... }
/// ```
class FilterBottomSheet extends ConsumerStatefulWidget {
  final ListingFilterParams currentFilters;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
  });

  /// Show the filter bottom sheet and return the new filter params,
  /// or null if cancelled.
  static Future<ListingFilterParams?> show(
    BuildContext context, {
    ListingFilterParams currentFilters = ListingFilterParams.defaultFilter,
  }) {
    return AppBottomSheet.show<ListingFilterParams>(
      context: context,
      child: FilterBottomSheet(currentFilters: currentFilters),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String? _categoryId;
  late String? _schoolId;
  late String? _areaId;
  late String _listingType; // 'rent', 'borrow', or ''
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = widget.currentFilters;
    _categoryId = f.categoryId;
    _schoolId = f.schoolId;
    _areaId = f.areaId;
    _listingType = f.listingType ?? '';
    if (f.minPrice != null) {
      _minPriceController.text = f.minPrice!.toStringAsFixed(0);
    }
    if (f.maxPrice != null) {
      _maxPriceController.text = f.maxPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _apply() {
    final min = double.tryParse(_minPriceController.text);
    final max = double.tryParse(_maxPriceController.text);

    Navigator.of(context).pop(
      ListingFilterParams.defaultFilter.copyWith(
        categoryId: _categoryId,
        schoolId: _schoolId,
        areaId: _areaId,
        listingType: _listingType.isEmpty ? null : _listingType,
        minPrice: min,
        maxPrice: max,
      ),
    );
  }

  void _reset() {
    setState(() {
      _categoryId = null;
      _schoolId = null;
      _areaId = null;
      _listingType = '';
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final schoolsAsync = ref.watch(schoolsProvider);
    final areasAsync = ref.watch(areasProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Text(
            'Bộ lọc',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Categories section
          Text(
            'Danh mục',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.neutral700),
          ),
          const SizedBox(height: 8),
          categoriesAsync.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const Text('Không thể tải danh mục'),
            data: (categories) => Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categories.map((cat) {
                final isSelected = _categoryId == cat.id;
                return AppChip(
                  label: cat.name,
                  isSelected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _categoryId = selected ? cat.id : null;
                    });
                  },
                );
              }).toList(),
            ),
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
          schoolsAsync.when(
            loading: () => const Text('Đang tải...'),
            error: (_, __) => const Text('Không thể tải danh sách trường'),
            data: (schools) => Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                AppChip(
                  label: 'Tất cả',
                  isSelected: _schoolId == null,
                  onSelected: (_) => setState(() => _schoolId = null),
                ),
                ...schools.map((s) {
                  final isSelected = _schoolId == s.id;
                  return AppChip(
                    label: s.name,
                    isSelected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _schoolId = selected ? s.id : null;
                      });
                    },
                  );
                }),
              ],
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
          areasAsync.when(
            loading: () => const Text('Đang tải...'),
            error: (_, __) => const Text('Không thể tải danh sách khu vực'),
            data: (areas) => Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                AppChip(
                  label: 'Tất cả',
                  isSelected: _areaId == null,
                  onSelected: (_) => setState(() => _areaId = null),
                ),
                ...areas.map((a) {
                  final isSelected = _areaId == a.id;
                  return AppChip(
                    label: a.name,
                    isSelected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _areaId = selected ? a.id : null;
                      });
                    },
                  );
                }),
              ],
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
          Row(
            children: [
              Expanded(
                child: AppChip(
                  label: 'Cho thuê',
                  isSelected: _listingType == 'rent',
                  onSelected: (selected) {
                    setState(() {
                      _listingType = selected ? 'rent' : '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppChip(
                  label: 'Cho mượn',
                  isSelected: _listingType == 'borrow',
                  onSelected: (selected) {
                    setState(() {
                      _listingType = selected ? 'borrow' : '';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price range (only for rent type)
          if (_listingType != 'borrow') ...[
            Text(
              'Khoảng giá (VNĐ/ngày)',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.neutral700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Từ',
                    hintText: '0',
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppInput(
                    label: 'Đến',
                    hintText: '1000000',
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Đặt lại',
                  onPressed: _reset,
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Áp dụng',
                  onPressed: _apply,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
