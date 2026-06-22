import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unishare/core/enums/listing_status.dart';
import 'package:unishare/core/enums/listing_type.dart';
import 'package:unishare/core/network/api_response.dart';
import 'package:unishare/config/app_config.dart';
import 'package:unishare/features/auth/presentation/providers/auth_provider.dart';
import 'package:unishare/features/auth/presentation/providers/auth_state.dart';
import 'package:unishare/features/listings/models/listing_summary_dto.dart';
import 'package:unishare/features/listings/models/listing_detail_dto.dart';
import 'package:unishare/features/reference/models/tag_dto.dart';
import 'package:unishare/features/listings/presentation/providers/listings_provider.dart';
import 'package:unishare/features/listings/presentation/screens/home_screen.dart';
import 'package:unishare/features/listings/presentation/screens/search_screen.dart';
import 'package:unishare/features/listings/presentation/screens/listing_detail_screen.dart';
import 'package:unishare/features/notifications/presentation/providers/notifications_provider.dart'
    show unreadCountProvider;
import 'package:unishare/features/reference/models/category_dto.dart';
import 'package:unishare/features/reference/models/school_dto.dart';
import 'package:unishare/features/reference/models/area_dto.dart';
import 'package:unishare/features/users/models/user_summary_dto.dart';
import 'package:unishare/features/users/models/user_profile_dto.dart';
import 'package:unishare/features/images/models/listing_image_dto.dart';

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

final _sampleOtherProfile = UserProfileDto(
  id: 'user-2',
  email: 'other@example.com',
  fullName: 'Tran Thi B',
  reputationScore: 80.0,
  totalReviews: 5,
  isVerified: false,
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

final _sampleOtherSummary = UserSummaryDto(
  id: 'user-2',
  fullName: 'Tran Thi B',
  avatarUrl: null,
  reputationScore: 80.0,
  totalReviews: 5,
);

ListingSummaryDto _sampleListing({
  String id = 'listing-1',
  String title = 'Sách Giải Tích',
  ListingType listingType = ListingType.rent,
  ListingStatus status = ListingStatus.available,
  double pricePerDay = 10000,
  double depositAmount = 50000,
  String? coverImageUrl,
}) {
  return ListingSummaryDto(
    id: id,
    title: title,
    coverImageUrl: coverImageUrl,
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
  String? conditionNote,
  List<TagDto>? tags,
  List<ListingImageDto>? images,
  UserSummaryDto? owner,
  int viewCount = 120,
  int upvoteCount = 5,
  int commentCount = 2,
}) {
  return ListingDetailDto(
    id: id,
    title: title,
    description: 'Sách Giải Tích tập 1, còn mới 95%, dùng cho kỳ 1 năm nhất.',
    listingType: listingType,
    status: status,
    pricePerDay: pricePerDay,
    depositAmount: depositAmount,
    conditionNote: conditionNote,
    category: const CategoryDto(id: 'cat-1', name: 'Sách vở'),
    school: const SchoolDto(id: 'school-1', name: 'Đại học Bách Khoa'),
    area: const AreaDto(id: 'area-1', name: 'Quận 10'),
    tags: tags,
    images: images,
    owner: owner ?? _sampleOwner,
    viewCount: viewCount,
    upvoteCount: upvoteCount,
    commentCount: commentCount,
    createdAt: DateTime(2026, 6, 1),
  );
}

// =============================================================================
// TESTS
// =============================================================================
void main() {
  // ===========================================================================
  // HomeScreen Widget Tests
  // ===========================================================================
  group('HomeScreen', () {
    testWidgets('renders app bar with title and notifications icon',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('UniShare'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.text('Tìm đồ dùng...'), findsOneWidget);
    });

    testWidgets('shows loading state when data is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.delayed(
                const Duration(seconds: 99),
                () => PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Đang tải bài đăng...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance past the 99s delayed future so no pending timer remains
      await tester.pump(const Duration(seconds: 100));
    });

    testWidgets('shows empty state when no listings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có bài đăng nào'), findsOneWidget);
      expect(
          find.text('Hãy quay lại sau để khám phá đồ dùng mới'), findsOneWidget);
    });

    testWidgets('shows error state when loading fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.error(Exception('Lỗi kết nối')),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Không thể tải danh sách bài đăng'),
          findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('shows listing cards when data is available', (tester) async {
      final listing = _sampleListing();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: [listing],
                  page: 1,
                  pageSize: 20,
                  totalItems: 1,
                  totalPages: 1,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sách Giải Tích'), findsOneWidget);
      expect(find.text('10000đ/ngày'), findsOneWidget);
      expect(find.text('Nguyen Van A'), findsOneWidget);
    });

    testWidgets('shows notification badge when unread count > 0',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(3)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows 99+ badge for large unread count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(120)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('shows borrow listing as Miễn phí', (tester) async {
      final borrowListing = _sampleListing(
        listingType: ListingType.borrow,
        pricePerDay: 0,
        depositAmount: 0,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: [borrowListing],
                  page: 1,
                  pageSize: 20,
                  totalItems: 1,
                  totalPages: 1,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Miễn phí'), findsOneWidget);
    });

    testWidgets('shows profile icon for authenticated users', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleProfile,
                  ),
                )),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('shows quick filter chips for authenticated users',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleProfile,
                  ),
                )),
            unreadCountProvider.overrideWith((ref) => Future.value(0)),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Đại học Bách Khoa'), findsOneWidget);
      expect(find.text('Quận 10'), findsOneWidget);
    });
  });

  // ===========================================================================
  // SearchScreen Widget Tests
  // ===========================================================================
  group('SearchScreen', () {
    testWidgets('renders search input and filter button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tìm kiếm'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows initial empty state with search prompt', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tìm kiếm đồ dùng cần chia sẻ'), findsOneWidget);
      expect(find.textContaining('Nhập từ khóa'), findsOneWidget);
    });

    testWidgets('shows clear button when keyword is entered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingsProvider.overrideWith(
              (ref, filters) => Future.value(
                PagedResponse<ListingSummaryDto>(
                  items: const [],
                  page: 1,
                  pageSize: 20,
                  totalItems: 0,
                  totalPages: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Sách');
      // Wait for the 300ms debounce timer to fire
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows empty results message when no matches', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingsProvider.overrideWith(
              (ref, filters) {
                // Search screen uses listingsProvider with the filter params
                // Return empty results for any keyword
                return Future.value(
                  PagedResponse<ListingSummaryDto>(
                    items: const [],
                    page: 1,
                    pageSize: 20,
                    totalItems: 0,
                    totalPages: 0,
                  ),
                );
              },
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy kết quả'), findsOneWidget);
    });

    testWidgets('shows search results with count', (tester) async {
      final listing = _sampleListing();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingsProvider.overrideWith(
              (ref, filters) {
                return Future.value(
                  PagedResponse<ListingSummaryDto>(
                    items: [listing],
                    page: 1,
                    pageSize: 20,
                    totalItems: 1,
                    totalPages: 1,
                  ),
                );
              },
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Sách');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tìm thấy'), findsOneWidget);
      expect(find.text('Sách Giải Tích'), findsOneWidget);
    });

    testWidgets('shows error state when search fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingsProvider.overrideWith(
              (ref, filters) => Future.error(Exception('Search error')),
            ),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'fail');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.textContaining('Không thể tìm kiếm'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ListingDetailScreen Widget Tests
  // ===========================================================================
  group('ListingDetailScreen', () {
    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 99),
                () => _sampleDetail(),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Đang tải thông tin...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance past the 99s delayed future so no pending timer remains
      await tester.pump(const Duration(seconds: 100));
    });

    testWidgets('shows error state when loading fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.error(Exception('Not found')),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Không thể tải thông tin bài đăng'),
          findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });

    testWidgets('renders title and price for rent listing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sách Giải Tích'), findsOneWidget);
      expect(find.text('10000đ/ngày'), findsOneWidget);
      expect(find.text('Mô tả'), findsOneWidget);
    });

    testWidgets('shows Miễn phí for borrow listing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(
                listingType: ListingType.borrow,
                pricePerDay: 0,
                depositAmount: 0,
              )),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Miễn phí'), findsOneWidget);
    });

    testWidgets('shows deposit amount for rent listing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) =>
                  Future.value(_sampleDetail(depositAmount: 100000)),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cọc: 100000đ'), findsOneWidget);
    });

    testWidgets('shows category, school, area info', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sách vở'), findsOneWidget);
      expect(find.text('Đại học Bách Khoa'), findsOneWidget);
      expect(find.text('Quận 10'), findsOneWidget);
    });

    testWidgets('shows owner card with name and reputation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('Uy tín: 95.5'), findsOneWidget);
    });

    testWidgets('shows tags when present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(
                _sampleDetail(tags: [
                  const TagDto(id: 'tag-1', name: 'toán'),
                  const TagDto(id: 'tag-2', name: 'giải tích'),
                  const TagDto(id: 'tag-3', name: 'năm nhất'),
                ]),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#toán'), findsOneWidget);
      expect(find.text('#giải tích'), findsOneWidget);
      expect(find.text('#năm nhất'), findsOneWidget);
    });

    testWidgets('shows condition note when present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(
                _sampleDetail(conditionNote: 'Còn mới 95%'),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tình trạng'), findsOneWidget);
      expect(find.text('Còn mới 95%'), findsOneWidget);
    });

    testWidgets('shows stats row with view/upvote/comment counts',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(
                viewCount: 150,
                upvoteCount: 25,
                commentCount: 8,
              )),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('150'), findsOneWidget);
      // "25" and "8" appear in both stats row and bottom action bar
      expect(find.text('25'), findsAtLeast(1));
      expect(find.text('8'), findsAtLeast(1));
    });

    testWidgets('shows image placeholder when no images', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(images: [])),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('shows "Gửi yêu cầu thuê" for rent listing as guest',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gửi yêu cầu thuê'), findsOneWidget);
    });

    testWidgets('shows "Gửi yêu cầu mượn" for borrow listing as guest',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(
                listingType: ListingType.borrow,
                pricePerDay: 0,
                depositAmount: 0,
              )),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gửi yêu cầu mượn'), findsOneWidget);
    });

    testWidgets('shows "Bài đăng của bạn" for owner', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleProfile,
                  ),
                )),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(owner: _sampleOwner)),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bài đăng của bạn'), findsOneWidget);
    });

    testWidgets('shows "Không khả dụng" when listing is not available',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(
                _sampleDetail(status: ListingStatus.closed),
              ),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Không khả dụng'), findsOneWidget);
    });

    testWidgets('hides chat button for owner', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleProfile,
                  ),
                )),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(owner: _sampleOwner)),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhắn tin'), findsNothing);
    });

    testWidgets('shows chat button for non-owner authenticated user',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleOtherProfile,
                  ),
                )),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail(owner: _sampleOwner)),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhắn tin'), findsOneWidget);
    });

    testWidgets('upvote and comment action buttons are present',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(AppConfig.dev),
            authProvider
                .overrideWith((ref) => _FakeAuthNotifier(AuthUnauthenticated())),
            listingDetailProvider('listing-1').overrideWith(
              (ref) => Future.value(_sampleDetail()),
            ),
          ],
          child: const MaterialApp(
            home: ListingDetailScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsWidgets);
      expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
    });
  });
}
