import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unishare/core/enums/listing_status.dart';
import 'package:unishare/core/enums/listing_type.dart';
import 'package:unishare/core/network/api_response.dart';
import 'package:unishare/config/app_config.dart';
import 'package:unishare/features/auth/presentation/providers/auth_provider.dart';
import 'package:unishare/features/auth/presentation/providers/auth_state.dart';
import 'package:unishare/features/interactions/models/upvote_response.dart';
import 'package:unishare/features/listings/data/listings_repository.dart';
import 'package:unishare/features/listings/models/create_listing_request.dart';
import 'package:unishare/features/listings/models/listing_detail_dto.dart';
import 'package:unishare/features/listings/models/listing_summary_dto.dart';
import 'package:unishare/features/listings/models/update_listing_request.dart';
import 'package:unishare/features/listings/presentation/providers/listing_form_provider.dart';
import 'package:unishare/features/listings/presentation/providers/listings_provider.dart';
import 'package:unishare/features/listings/presentation/providers/my_listings_provider.dart';
import 'package:unishare/features/listings/presentation/screens/create_listing_screen.dart';
import 'package:unishare/features/listings/presentation/screens/edit_listing_screen.dart';
import 'package:unishare/features/listings/presentation/screens/my_listings_screen.dart';
import 'package:unishare/features/reference/models/category_dto.dart';
import 'package:unishare/features/reference/models/school_dto.dart';
import 'package:unishare/features/reference/models/area_dto.dart';
import 'package:unishare/features/reference/models/tag_dto.dart';
import 'package:unishare/features/reference/presentation/providers/reference_provider.dart';
import 'package:unishare/features/users/models/user_summary_dto.dart';
import 'package:unishare/features/users/models/user_profile_dto.dart';
import 'package:unishare/shared/widgets/app_button.dart';

// =============================================================================
// Fake auth notifier
// =============================================================================
class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier(super.state);

  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> register({
    required String email,
    String? phoneNumber,
    required String password,
    required String fullName,
  }) async {}
  @override
  Future<void> tryAutoLogin() async {}
}

// =============================================================================
// Sample data
// =============================================================================

final _sampleProfile = UserProfileDto(
  id: 'owner-1',
  email: 'owner@example.com',
  fullName: 'Nguyen Van A',
  avatarUrl: null,
  schoolId: 'school-1',
  schoolName: 'Đại học Bách Khoa',
  areaId: 'area-1',
  areaName: 'Quận 10',
  reputationScore: 95.5,
  totalReviews: 12,
  isVerified: true,
);

final _sampleOwner = UserSummaryDto(
  id: 'owner-1',
  fullName: 'Nguyen Van A',
  avatarUrl: null,
  schoolName: 'Đại học Bách Khoa',
  areaName: 'Quận 10',
  reputationScore: 95.5,
  totalReviews: 12,
);

ListingSummaryDto _sampleListing({
  String id = 'listing-1',
  String title = 'Sách Giải Tích',
  ListingType listingType = ListingType.rent,
  ListingStatus status = ListingStatus.available,
  double pricePerDay = 10000,
  double depositAmount = 50000,
}) {
  return ListingSummaryDto(
    id: id,
    title: title,
    coverImageUrl: null,
    listingType: listingType,
    status: status,
    pricePerDay: pricePerDay,
    depositAmount: depositAmount,
    categoryName: 'Sách vở',
    schoolName: 'Đại học Bách Khoa',
    areaName: 'Quận 10',
    owner: _sampleOwner,
    upvoteCount: 5,
    commentCount: 2,
    createdAt: DateTime(2026, 6, 1),
  );
}

ListingDetailDto _sampleDetail({
  String id = 'listing-1',
  String title = 'Sách Giải Tích',
  ListingType listingType = ListingType.rent,
  ListingStatus status = ListingStatus.available,
  double pricePerDay = 10000,
  double depositAmount = 50000,
  UserSummaryDto? owner,
}) {
  return ListingDetailDto(
    id: id,
    title: title,
    description: 'Sách Giải Tích tập 1, còn mới 95%.',
    listingType: listingType,
    status: status,
    pricePerDay: pricePerDay,
    depositAmount: depositAmount,
    conditionNote: 'Còn mới',
    category: const CategoryDto(id: 'cat-1', name: 'Sách vở'),
    school: const SchoolDto(id: 'school-1', name: 'Đại học Bách Khoa'),
    area: const AreaDto(id: 'area-1', name: 'Quận 10'),
    tags: const [
      TagDto(id: 'tag-1', name: 'toán'),
      TagDto(id: 'tag-2', name: 'giải tích'),
    ],
    images: null,
    owner: owner ?? _sampleOwner,
    viewCount: 120,
    upvoteCount: 5,
    commentCount: 2,
    createdAt: DateTime(2026, 6, 1),
  );
}

final _sampleCategories = const [
  CategoryDto(id: 'cat-1', name: 'Sách vở', icon: '📚'),
  CategoryDto(id: 'cat-2', name: 'Điện tử', icon: '💻'),
  CategoryDto(id: 'cat-3', name: 'Đồ gia dụng', icon: '🏠'),
];

final _sampleSchools = const [
  SchoolDto(id: 'school-1', name: 'Đại học Bách Khoa'),
  SchoolDto(id: 'school-2', name: 'Đại học Khoa học Tự nhiên'),
];

final _sampleAreas = const [
  AreaDto(id: 'area-1', name: 'Quận 10'),
  AreaDto(id: 'area-2', name: 'Quận 1'),
];

// =============================================================================
// Fake ListingsRepository for use with ListingFormNotifier
// =============================================================================
class _FakeListingsRepository implements ListingsRepository {
  @override
  Future<PagedResponse<ListingSummaryDto>> getListings({
    String? keyword,
    String? categoryId,
    String? tag,
    String? schoolId,
    String? areaId,
    ListingType? listingType,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    return PagedResponse<ListingSummaryDto>(
      items: const [],
      page: 1,
      pageSize: 20,
      totalItems: 0,
      totalPages: 0,
    );
  }

  @override
  Future<ListingDetailDto> getListingDetail(String listingId) async {
    return _sampleDetail();
  }

  @override
  Future<ListingDetailDto> createListing(CreateListingRequest request) async {
    return _sampleDetail();
  }

  @override
  Future<ListingDetailDto> updateListing(
    String listingId,
    UpdateListingRequest request,
  ) async {
    return _sampleDetail();
  }

  @override
  Future<void> closeListing(String listingId) async {}

  @override
  Future<void> deleteListing(String listingId) async {}

  @override
  Future<PagedResponse<ListingSummaryDto>> getMyListings({
    ListingStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return PagedResponse<ListingSummaryDto>(
      items: const [],
      page: 1,
      pageSize: 20,
      totalItems: 0,
      totalPages: 0,
    );
  }

  @override
  Future<UpvoteResponse> toggleUpvote(String listingId, bool isUpvoted) async {
    return UpvoteResponse(
      listingId: listingId,
      isUpvoted: !isUpvoted,
      upvoteCount: 1,
    );
  }
}

// =============================================================================
// Provider overrides
// =============================================================================
List<Override> _authOverrides(UserProfileDto user) {
  return [
    authProvider.overrideWith((ref) => _FakeAuthNotifier(
          AuthAuthenticated(
            accessToken: 'token',
            refreshToken: 'refresh',
            user: user,
          ),
        )),
  ];
}

List<Override> _refOverrides() {
  return [
    categoriesProvider.overrideWith((ref) => Future.value(_sampleCategories)),
    schoolsProvider.overrideWith((ref) => Future.value(_sampleSchools)),
    areasProvider.overrideWith((ref) => Future.value(_sampleAreas)),
  ];
}

List<Override> _repoOverrides() {
  return [
    listingsRepositoryProvider
        .overrideWith((ref) => _FakeListingsRepository()),
  ];
}

// =============================================================================
// Fake MyListingsNotifier that doesn't auto-load (keeps the state we set)
// =============================================================================
class _FakeMyListingsNotifier extends MyListingsNotifier {
  _FakeMyListingsNotifier() : super(_FakeListingsRepository());

  @override
  Future<void> loadListings({bool refresh = false}) async {
    // no-op: keep whatever state we manually set
  }

  @override
  Future<void> loadMore() async {
    // no-op
  }
}

// =============================================================================
// TESTS
// =============================================================================
void main() {
  // ===========================================================================
  // CreateListingScreen
  // ===========================================================================
  group('CreateListingScreen', () {
    Future<void> pumpCreate(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            ..._refOverrides(),
            ..._repoOverrides(),
          ],
          child: const MaterialApp(home: CreateListingScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders app bar and visible form fields', (tester) async {
      await pumpCreate(tester);

      expect(find.text('Đăng đồ dùng'), findsOneWidget);
      expect(find.text('Tiêu đề *'), findsOneWidget);
      expect(find.text('Danh mục *'), findsOneWidget);
      expect(find.text('Hình thức'), findsOneWidget);
      expect(find.text('Cho thuê'), findsOneWidget);
      expect(find.text('Cho mượn'), findsOneWidget);
      expect(find.byType(SegmentedButton<ListingType>), findsOneWidget);
      expect(find.text('Giá/ngày (VNĐ) *'), findsOneWidget);
      expect(find.text('Tiền cọc (VNĐ)'), findsOneWidget);
    });

    testWidgets('renders fields below viewport after scrolling',
        (tester) async {
      await pumpCreate(tester);

      // Scroll down to find submit button
      await tester.scrollUntilVisible(
        find.text('Tiếp theo - Thêm ảnh'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Tiếp theo - Thêm ảnh'), findsOneWidget);
      expect(find.text('Mô tả *'), findsOneWidget);
      expect(find.text('Trường học'), findsOneWidget);
      expect(find.text('Khu vực'), findsOneWidget);
      expect(find.text('Thẻ tag'), findsOneWidget);
    });

    testWidgets('validates required fields on empty submit', (tester) async {
      await pumpCreate(tester);

      // Scroll to submit button and tap
      await tester.scrollUntilVisible(
        find.text('Tiếp theo - Thêm ảnh'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Tiếp theo - Thêm ảnh'));
      await tester.pumpAndSettle();

      // Verify form state has validation errors set
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CreateListingScreen)),
      );
      final formState = container.read(listingFormProvider);
      expect(formState.titleError, 'Vui lòng nhập tiêu đề');
      expect(formState.descriptionError, 'Vui lòng nhập mô tả');
      expect(formState.categoryError, 'Vui lòng chọn danh mục');
      expect(formState.hasSubmitted, isTrue);
    });

    testWidgets('hides deposit field for borrow type', (tester) async {
      await pumpCreate(tester);

      await tester.tap(find.text('Cho mượn'));
      await tester.pumpAndSettle();

      expect(find.text('Tiền cọc (VNĐ)'), findsNothing);
      expect(find.text('Giá/ngày (miễn phí)'), findsOneWidget);
    });

    testWidgets('shows picker placeholders', (tester) async {
      await pumpCreate(tester);

      expect(find.text('Chọn danh mục'), findsOneWidget);
      // Scroll down for school/area pickers
      await tester.scrollUntilVisible(
        find.text('Chọn trường (tùy chọn)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Chọn trường (tùy chọn)'), findsOneWidget);
      expect(find.text('Chọn khu vực (tùy chọn)'), findsOneWidget);
    });
  });

  // ===========================================================================
  // EditListingScreen
  // ===========================================================================
  group('EditListingScreen', () {
    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            ..._refOverrides(),
            ..._repoOverrides(),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 99),
                () => _sampleDetail(),
              ),
            ),
          ],
          child: const MaterialApp(
            home: EditListingScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Đang tải thông tin bài đăng...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance past the 99s timer
      await tester.pump(const Duration(seconds: 100));
    });

    testWidgets('shows error state when listing fails to load',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            ..._refOverrides(),
            ..._repoOverrides(),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.error(Exception('Not found')),
            ),
          ],
          child: const MaterialApp(
            home: EditListingScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Không thể tải bài đăng'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('renders edit form with pre-filled data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            ..._refOverrides(),
            ..._repoOverrides(),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: EditListingScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sửa bài đăng'), findsOneWidget);
      // Category should be pre-filled (visible without scrolling)
      expect(find.text('Sách vở'), findsOneWidget);

      // Scroll down for save/close/delete buttons
      await tester.scrollUntilVisible(
        find.text('Lưu thay đổi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Lưu thay đổi'), findsOneWidget);
      expect(find.text('Đóng bài đăng'), findsOneWidget);
      expect(find.text('Xóa bài đăng'), findsOneWidget);

      // School/area pre-filled
      expect(find.text('Đại học Bách Khoa'), findsOneWidget);
      expect(find.text('Quận 10'), findsOneWidget);
    });

    testWidgets('shows overflow menu button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            ..._refOverrides(),
            ..._repoOverrides(),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: EditListingScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });

  // ===========================================================================
  // MyListingsScreen
  // ===========================================================================
  group('MyListingsScreen', () {
    testWidgets('shows loading state initially', (tester) async {
      final notifier = _FakeMyListingsNotifier();
      notifier.state = const MyListingsState(isLoading: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      // Use pump() — CircularProgressIndicator animates forever
      await tester.pump();

      expect(find.text('Đang tải...'), findsOneWidget);
    });

    testWidgets('shows empty state when no listings', (tester) async {
      final notifier = _FakeMyListingsNotifier();
      notifier.state = const MyListingsState(
        isLoading: false,
        listings: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bạn chưa có bài đăng nào'), findsOneWidget);
      expect(find.text('Đăng bài ngay'), findsOneWidget);
    });

    testWidgets('shows error state when loading fails', (tester) async {
      final notifier = _FakeMyListingsNotifier();
      notifier.state = const MyListingsState(
        isLoading: false,
        errorMessage: 'Lỗi kết nối',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lỗi kết nối'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('shows status filter chips', (tester) async {
      final notifier = _FakeMyListingsNotifier();
      notifier.state =
          const MyListingsState(isLoading: false, listings: []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Đang cho thuê'), findsOneWidget);
      expect(find.text('Đã được đặt'), findsOneWidget);
      expect(find.text('Đang sử dụng'), findsOneWidget);
      expect(find.text('Đã đóng'), findsOneWidget);
    });

    testWidgets('shows listing cards with action buttons for available',
        (tester) async {
      final listing = _sampleListing();
      final notifier = _FakeMyListingsNotifier();
      notifier.state = MyListingsState(
        isLoading: false,
        listings: [listing],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sách Giải Tích'), findsOneWidget);
      expect(find.text('Sửa'), findsOneWidget);
      expect(find.text('Đóng'), findsOneWidget);
    });

    testWidgets('shows delete button for closed listings', (tester) async {
      final closedListing = _sampleListing(status: ListingStatus.closed);
      final notifier = _FakeMyListingsNotifier();
      notifier.state = MyListingsState(
        isLoading: false,
        listings: [closedListing],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Xóa'), findsOneWidget);
      expect(find.text('Sửa'), findsNothing);
      expect(find.text('Đóng'), findsNothing);
    });

    testWidgets('shows app bar title', (tester) async {
      final notifier = _FakeMyListingsNotifier();
      notifier.state =
          const MyListingsState(isLoading: false, listings: []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bài đăng của tôi'), findsOneWidget);
    });

    testWidgets('shows loading more indicator', (tester) async {
      final listing = _sampleListing();
      final notifier = _FakeMyListingsNotifier();
      notifier.state = MyListingsState(
        isLoading: false,
        isLoadingMore: true,
        listings: [listing],
        hasMore: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            ..._authOverrides(_sampleProfile),
            myListingsProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: MyListingsScreen()),
        ),
      );
      // Use pump() to avoid hanging on infinite spinner animation
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
