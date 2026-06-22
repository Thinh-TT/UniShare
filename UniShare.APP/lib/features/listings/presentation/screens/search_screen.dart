import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/listing_card.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/listings_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  ListingFilterParams _filters = ListingFilterParams.defaultFilter;
  Timer? _debounceTimer;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _hasSearched = true;
        _filters = _filters.copyWith(
          keyword: value.isEmpty ? null : value,
          page: 1,
          clearKeyword: value.isEmpty,
        );
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filters = _filters.copyWith(clearKeyword: true, page: 1);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final currentData = ref.read(listingsProvider(_filters));
      currentData.whenData((paged) {
        if (paged.hasMore) {
          final nextPage = paged.page + 1;
          _filters = _filters.copyWith(page: nextPage);
          ref.invalidate(listingsProvider(_filters));
        }
      });
    }
  }

  Future<void> _openFilters() async {
    final result = await FilterBottomSheet.show(
      context,
      currentFilters: _filters,
    );
    if (result != null && mounted) {
      setState(() {
        _hasSearched = true;
        _filters = result.copyWith(
          keyword: _filters.keyword,
          page: 1,
        );
      });
    }
  }

  void _navigateToDetail(String listingId) {
    context.push('/search/listings/$listingId');
  }

  void _removeFilter({
    bool clearCategory = false,
    bool clearSchool = false,
    bool clearArea = false,
    bool clearType = false,
  }) {
    setState(() {
      _filters = _filters.copyWith(
        clearCategoryId: clearCategory,
        clearSchoolId: clearSchool,
        clearAreaId: clearArea,
        clearListingType: clearType,
        page: 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasKeyword = _filters.keyword != null && _filters.keyword!.isNotEmpty;
    final listingsAsync = _hasSearched
        ? ref.watch(listingsProvider(_filters))
        : null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Tìm kiếm'),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên đồ cần tìm...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.neutral500),
                      suffixIcon: hasKeyword
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  size: 20, color: AppColors.neutral500),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _filters.hasActiveFilters
                        ? AppColors.green
                        : AppColors.neutral700,
                  ),
                  onPressed: _openFilters,
                  tooltip: 'Bộ lọc',
                ),
              ],
            ),
          ),

          // Active filter chips
          if (_filters.hasActiveFilters) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_filters.categoryId != null)
                    _buildActiveFilter(
                      label: 'Danh mục',
                      onRemove: () => _removeFilter(clearCategory: true),
                    ),
                  if (_filters.schoolId != null)
                    _buildActiveFilter(
                      label: 'Trường',
                      onRemove: () => _removeFilter(clearSchool: true),
                    ),
                  if (_filters.areaId != null)
                    _buildActiveFilter(
                      label: 'Khu vực',
                      onRemove: () => _removeFilter(clearArea: true),
                    ),
                  if (_filters.listingType != null)
                    _buildActiveFilter(
                      label: _filters.listingType == 'rent'
                          ? 'Cho thuê'
                          : 'Cho mượn',
                      onRemove: () => _removeFilter(clearType: true),
                    ),
                  if (_filters.minPrice != null || _filters.maxPrice != null)
                    _buildActiveFilter(
                      label: _buildPriceLabel(),
                      onRemove: () {
                        setState(() {
                          _filters = _filters.copyWith(
                            clearMinPrice: true,
                            clearMaxPrice: true,
                            page: 1,
                          );
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Results
          Expanded(
            child: listingsAsync == null
                ? const EmptyState(
                    icon: Icons.search,
                    title: 'Tìm kiếm đồ dùng cần chia sẻ',
                    subtitle: 'Nhập từ khóa hoặc sử dụng bộ lọc để tìm đồ',
                  )
                : listingsAsync.when(
                    loading: () => const LoadingState(
                        message: 'Đang tìm kiếm...'),
                    error: (error, _) => ErrorState(
                      message:
                          'Không thể tìm kiếm.\n${error.toString()}',
                      onRetry: () {
                        setState(() {
                          _filters = _filters.copyWith(page: 1);
                        });
                      },
                    ),
                    data: (paged) {
                      if (paged.items.isEmpty) {
                        return EmptyState(
                          icon: Icons.search_off,
                          title: 'Không tìm thấy kết quả',
                          subtitle:
                              'Thử thay đổi từ khóa hoặc bộ lọc',
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Text(
                              'Tìm thấy ${paged.totalItems} kết quả',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppColors.neutral500),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 16),
                              itemCount: paged.items.length +
                                  (paged.hasMore ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index >= paged.items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.green,
                                      ),
                                    ),
                                  );
                                }

                                final listing =
                                    paged.items[index];
                                return ListingCard(
                                  listing: listing,
                                  onTap: () => _navigateToDetail(
                                      listing.id),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _buildPriceLabel() {
    final min = _filters.minPrice;
    final max = _filters.maxPrice;
    if (min != null && max != null) {
      return '${min.toStringAsFixed(0)}đ - ${max.toStringAsFixed(0)}đ';
    }
    if (min != null) return 'Từ ${min.toStringAsFixed(0)}đ';
    if (max != null) return 'Đến ${max.toStringAsFixed(0)}đ';
    return 'Giá';
  }

  Widget _buildActiveFilter({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.greenDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 16, color: AppColors.greenDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
