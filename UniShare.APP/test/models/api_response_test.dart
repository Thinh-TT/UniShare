import 'package:flutter_test/flutter_test.dart';
import 'package:unishare/core/network/api_response.dart';
import 'package:unishare/core/errors/app_exception.dart';
import 'package:unishare/features/auth/models/login_request.dart';
import 'package:unishare/features/auth/models/login_response.dart';
import 'package:unishare/features/auth/models/register_request.dart';
import 'package:unishare/features/users/models/user_profile_dto.dart';
import 'package:unishare/features/users/models/user_summary_dto.dart';
import 'package:unishare/features/users/models/update_profile_request.dart';
import 'package:unishare/features/listings/models/listing_summary_dto.dart';
import 'package:unishare/features/listings/models/listing_detail_dto.dart';
import 'package:unishare/features/reference/models/category_dto.dart';
import 'package:unishare/features/reference/models/school_dto.dart';
import 'package:unishare/features/reference/models/area_dto.dart';
import 'package:unishare/features/reference/models/tag_dto.dart';
import 'package:unishare/features/rentals/models/rental_request_dto.dart';
import 'package:unishare/features/rentals/models/rental_request_detail_dto.dart';
import 'package:unishare/features/reviews/models/review_dto.dart';
import 'package:unishare/features/notifications/models/notification_dto.dart';
import 'package:unishare/features/images/models/listing_image_dto.dart';
import 'package:unishare/core/enums/listing_type.dart';
import 'package:unishare/core/enums/listing_status.dart';
import 'package:unishare/core/enums/rental_request_status.dart';
import 'package:unishare/core/enums/deposit_status.dart';
import 'package:unishare/core/enums/notification_type.dart';

void main() {
  // =========================================================================
  // 1. ApiResponse<T> — single-object wrapper
  // =========================================================================
  group('ApiResponse<T>', () {
    test('parses success response with data', () {
      final json = {
        'data': {'id': 'user-1', 'fullName': 'Nguyen Van A'},
        'message': 'Success',
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (json) => json as Map<String, dynamic>,
      );

      expect(response.data, isNotNull);
      expect(response.data!['id'], 'user-1');
      expect(response.data!['fullName'], 'Nguyen Van A');
      expect(response.message, 'Success');
    });

    test('parses response with null data', () {
      final json = {
        'data': null,
        'message': 'No content',
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (json) => json as Map<String, dynamic>,
      );

      expect(response.data, isNull);
      expect(response.message, 'No content');
    });

    test('parses response with missing message field', () {
      final json = {
        'data': {'id': 'x'},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (json) => json as Map<String, dynamic>,
      );

      expect(response.data, isNotNull);
      expect(response.message, isNull);
    });

    test('toJson produces correct map', () {
      const response = ApiResponse<Map<String, dynamic>>(
        data: {'key': 'value'},
        message: 'OK',
      );

      final json = response.toJson((value) => value);

      expect(json['data'], {'key': 'value'});
      expect(json['message'], 'OK');
    });

    test('ApiResponse with typed DTO parsing', () {
      final json = {
        'data': {
          'id': 'cat-1',
          'name': 'Điện tử',
          'slug': 'dien-tu',
          'icon': 'laptop',
        },
      };

      final response = ApiResponse<CategoryDto>.fromJson(
        json,
        (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
      );

      expect(response.data, isA<CategoryDto>());
      expect(response.data!.id, 'cat-1');
      expect(response.data!.name, 'Điện tử');
    });
  });

  // =========================================================================
  // 2. PagedResponse<T> — paginated list wrapper
  // =========================================================================
  group('PagedResponse<T>', () {
    test('parses paged response correctly', () {
      final json = {
        'items': [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ],
        'page': 1,
        'pageSize': 10,
        'totalItems': 25,
        'totalPages': 3,
      };

      final response = PagedResponse<Map<String, dynamic>>.fromJson(
        json,
        (json) => json as Map<String, dynamic>,
      );

      expect(response.items, hasLength(2));
      expect(response.items[0]['name'], 'Item 1');
      expect(response.page, 1);
      expect(response.pageSize, 10);
      expect(response.totalItems, 25);
      expect(response.totalPages, 3);
    });

    test('hasMore returns true when more pages exist', () {
      final response = PagedResponse<Map<String, dynamic>>(
        items: [],
        page: 1,
        pageSize: 10,
        totalItems: 25,
        totalPages: 3,
      );

      expect(response.hasMore, isTrue);
    });

    test('hasMore returns false on last page', () {
      final response = PagedResponse<Map<String, dynamic>>(
        items: [],
        page: 3,
        pageSize: 10,
        totalItems: 25,
        totalPages: 3,
      );

      expect(response.hasMore, isFalse);
    });

    test('hasMore works without totalPages field', () {
      final response = PagedResponse<Map<String, dynamic>>(
        items: [],
        page: 2,
        pageSize: 10,
        totalItems: 20,
      );

      expect(response.hasMore, isFalse);
    });

    test('parses empty items list', () {
      final json = {
        'items': [],
        'page': 1,
        'pageSize': 10,
        'totalItems': 0,
      };

      final response = PagedResponse<Map<String, dynamic>>.fromJson(
        json,
        (json) => json as Map<String, dynamic>,
      );

      expect(response.items, isEmpty);
      expect(response.totalItems, 0);
      expect(response.hasMore, isFalse);
    });

    test('parses paged response with typed DTOs', () {
      final json = {
        'items': [
          {
            'id': 'cat-1',
            'name': 'Điện tử',
            'slug': 'dien-tu',
            'icon': 'laptop',
          },
          {
            'id': 'cat-2',
            'name': 'Sách',
            'slug': 'sach',
            'icon': 'book',
          },
        ],
        'page': 1,
        'pageSize': 20,
        'totalItems': 2,
      };

      final response = PagedResponse<CategoryDto>.fromJson(
        json,
        (json) => CategoryDto.fromJson(json as Map<String, dynamic>),
      );

      expect(response.items, hasLength(2));
      expect(response.items[0], isA<CategoryDto>());
      expect(response.items[1].name, 'Sách');
    });

    test('toJson produces correct map', () {
      const response = PagedResponse<Map<String, dynamic>>(
        items: [{'a': 1}],
        page: 1,
        pageSize: 10,
        totalItems: 1,
        totalPages: 1,
      );

      final json = response.toJson((value) => value);

      expect(json['items'], [{'a': 1}]);
      expect(json['page'], 1);
      expect(json['pageSize'], 10);
      expect(json['totalItems'], 1);
    });
  });

  // =========================================================================
  // 3. ProblemDetails — error response
  // =========================================================================
  group('ProblemDetails', () {
    test('parses validation error response', () {
      final json = {
        'type': 'https://tools.ietf.org/html/rfc7231#section-6.5.1',
        'title': 'One or more validation errors occurred.',
        'status': 422,
        'detail': 'Validation failed',
        'errors': {
          'email': ['Email is required', 'Email is not valid'],
          'password': ['Password must be at least 6 characters'],
        },
      };

      final problem = ProblemDetails.fromJson(json);

      expect(problem.status, 422);
      expect(problem.title, 'One or more validation errors occurred.');
      expect(problem.errors, isNotNull);
      expect(problem.errors!['email'], hasLength(2));
      expect(problem.errors!['password'], hasLength(1));
    });

    test('parses not found error response', () {
      final json = {
        'type': 'https://tools.ietf.org/html/rfc7231#section-6.5.4',
        'title': 'Not Found',
        'status': 404,
        'detail': 'Listing not found',
      };

      final problem = ProblemDetails.fromJson(json);

      expect(problem.status, 404);
      expect(problem.detail, 'Listing not found');
      expect(problem.errors, isNull);
    });

    test('parses minimal error response', () {
      final json = {
        'status': 500,
      };

      final problem = ProblemDetails.fromJson(json);

      expect(problem.status, 500);
      expect(problem.type, isNull);
      expect(problem.title, isNull);
      expect(problem.detail, isNull);
    });

    test('toJson produces correct map', () {
      const problem = ProblemDetails(
        type: 'about:blank',
        title: 'Bad Request',
        status: 400,
        detail: 'Invalid input',
      );

      final json = problem.toJson();

      expect(json['status'], 400);
      expect(json['title'], 'Bad Request');
      expect(json['detail'], 'Invalid input');
    });
  });

  // =========================================================================
  // 4. AppException hierarchy
  // =========================================================================
  group('AppException', () {
    test('NetworkException has null statusCode', () {
      const ex = NetworkException(message: 'No connection');
      expect(ex.message, 'No connection');
      expect(ex.statusCode, isNull);
      expect(ex.toString(), 'No connection');
    });

    test('UnauthorizedException has statusCode 401', () {
      const ex = UnauthorizedException();
      expect(ex.statusCode, 401);
      expect(ex.message, 'Unauthorized');
    });

    test('UnauthorizedException with custom message', () {
      const ex = UnauthorizedException(message: 'Token expired');
      expect(ex.statusCode, 401);
      expect(ex.message, 'Token expired');
    });

    test('ForbiddenException has statusCode 403', () {
      const ex = ForbiddenException();
      expect(ex.statusCode, 403);
    });

    test('NotFoundException has statusCode 404', () {
      const ex = NotFoundException();
      expect(ex.statusCode, 404);
    });

    test('ConflictException has statusCode 409', () {
      const ex = ConflictException();
      expect(ex.statusCode, 409);
    });

    test('ValidationException has statusCode 422 and errors map', () {
      const ex = ValidationException(
        message: 'Invalid data',
        errors: {'email': ['Required']},
      );
      expect(ex.statusCode, 422);
      expect(ex.errors, isNotNull);
      expect(ex.errors!['email'], ['Required']);
    });

    test('ServerException has statusCode 500', () {
      const ex = ServerException();
      expect(ex.statusCode, 500);
    });

    test('AppException is catchable as Exception', () {
      const ex = AppException(message: 'test');
      expect(ex, isA<Exception>());
    });
  });

  // =========================================================================
  // 5. Auth DTO parsing
  // =========================================================================
  group('Auth DTOs', () {
    group('LoginRequest', () {
      test('fromJson parses correctly', () {
        final json = {'login': 'user@example.com', 'password': 'secret123'};
        final req = LoginRequest.fromJson(json);
        expect(req.login, 'user@example.com');
        expect(req.password, 'secret123');
      });

      test('toJson produces correct map', () {
        const req = LoginRequest(login: 'user@example.com', password: 'pass');
        final json = req.toJson();
        expect(json['login'], 'user@example.com');
        expect(json['password'], 'pass');
      });
    });

    group('RegisterRequest', () {
      test('fromJson parses correctly with optional phone', () {
        final json = {
          'email': 'user@example.com',
          'phoneNumber': '0912345678',
          'password': 'secret123',
          'fullName': 'Nguyen Van A',
        };
        final req = RegisterRequest.fromJson(json);
        expect(req.email, 'user@example.com');
        expect(req.phoneNumber, '0912345678');
        expect(req.password, 'secret123');
        expect(req.fullName, 'Nguyen Van A');
      });

      test('fromJson parses correctly without phone', () {
        final json = {
          'email': 'user@example.com',
          'password': 'secret123',
          'fullName': 'Nguyen Van A',
        };
        final req = RegisterRequest.fromJson(json);
        expect(req.phoneNumber, isNull);
      });

      test('toJson omits null phoneNumber', () {
        const req = RegisterRequest(
          email: 'user@example.com',
          password: 'secret123',
          fullName: 'Nguyen Van A',
        );
        final json = req.toJson();
        expect(json['phoneNumber'], isNull);
      });
    });

    group('LoginResponse', () {
      test('fromJson parses nested user correctly', () {
        final json = {
          'accessToken': 'eyJhbGciOi...',
          'refreshToken': 'refresh-token-123',
          'expiresIn': 3600,
          'user': {
            'id': 'user-1',
            'email': 'user@example.com',
            'fullName': 'Nguyen Van A',
            'reputationScore': 100.0,
            'totalReviews': 5,
            'isVerified': true,
          },
        };

        final response = LoginResponse.fromJson(json);

        expect(response.accessToken, 'eyJhbGciOi...');
        expect(response.refreshToken, 'refresh-token-123');
        expect(response.expiresIn, 3600);
        expect(response.user, isA<UserProfileDto>());
        expect(response.user.id, 'user-1');
        expect(response.user.fullName, 'Nguyen Van A');
        expect(response.user.reputationScore, 100.0);
        expect(response.user.isVerified, isTrue);
      });

      test('toJson produces correct map', () {
        final user = UserProfileDto(
          id: 'u1',
          email: 'a@b.com',
          fullName: 'Test',
          reputationScore: 0,
          totalReviews: 0,
          isVerified: false,
        );
        final response = LoginResponse(
          accessToken: 'at',
          refreshToken: 'rt',
          expiresIn: 3600,
          user: user,
        );

        final json = response.toJson();
        expect(json['accessToken'], 'at');
        expect(json['refreshToken'], 'rt');
        expect(json['expiresIn'], 3600);
        expect(json['user'], isNotNull);
      });
    });
  });

  // =========================================================================
  // 6. User DTO parsing
  // =========================================================================
  group('User DTOs', () {
    group('UserProfileDto', () {
      test('fromJson parses full profile correctly', () {
        final json = {
          'id': 'user-1',
          'email': 'user@example.com',
          'phoneNumber': '0912345678',
          'fullName': 'Nguyen Van A',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'schoolId': 'school-1',
          'schoolName': 'Đại học Bách Khoa',
          'areaId': 'area-1',
          'areaName': 'Quận 10',
          'reputationScore': 95.5,
          'totalReviews': 12,
          'isVerified': true,
        };

        final profile = UserProfileDto.fromJson(json);

        expect(profile.id, 'user-1');
        expect(profile.email, 'user@example.com');
        expect(profile.phoneNumber, '0912345678');
        expect(profile.fullName, 'Nguyen Van A');
        expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(profile.schoolId, 'school-1');
        expect(profile.schoolName, 'Đại học Bách Khoa');
        expect(profile.areaId, 'area-1');
        expect(profile.areaName, 'Quận 10');
        expect(profile.reputationScore, 95.5);
        expect(profile.totalReviews, 12);
        expect(profile.isVerified, isTrue);
      });

      test('fromJson parses minimal profile', () {
        final json = {
          'id': 'user-2',
          'email': 'minimal@example.com',
          'fullName': 'Minimal',
          'reputationScore': 80.0,
          'totalReviews': 0,
          'isVerified': false,
        };

        final profile = UserProfileDto.fromJson(json);

        expect(profile.phoneNumber, isNull);
        expect(profile.schoolName, isNull);
        expect(profile.areaName, isNull);
        expect(profile.avatarUrl, isNull);
      });

      test('toJson round-trips correctly', () {
        const profile = UserProfileDto(
          id: 'u1',
          email: 'test@test.com',
          fullName: 'Test User',
          phoneNumber: '0987654321',
          reputationScore: 100,
          totalReviews: 3,
          isVerified: true,
        );

        final json = profile.toJson();
        expect(json['id'], 'u1');
        expect(json['email'], 'test@test.com');
        expect(json['fullName'], 'Test User');
        expect(json['reputationScore'], 100);
        // null fields should be absent
        expect(json['schoolId'], isNull);
      });
    });

    group('UserSummaryDto', () {
      test('fromJson parses correctly', () {
        final json = {
          'id': 'user-1',
          'fullName': 'Nguyen Van A',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'schoolName': 'Đại học Bách Khoa',
          'areaName': 'Quận 10',
          'reputationScore': 95.5,
          'totalReviews': 12,
        };

        final summary = UserSummaryDto.fromJson(json);

        expect(summary.id, 'user-1');
        expect(summary.fullName, 'Nguyen Van A');
        expect(summary.reputationScore, 95.5);
        expect(summary.totalReviews, 12);
      });
    });

    group('UpdateProfileRequest', () {
      test('toJson omits null optional fields', () {
        const req = UpdateProfileRequest(fullName: 'New Name');
        final json = req.toJson();

        expect(json['fullName'], 'New Name');
        expect(json['phoneNumber'], isNull);
        expect(json['schoolId'], isNull);
        expect(json['areaId'], isNull);
      });

      test('toJson includes all fields when set', () {
        const req = UpdateProfileRequest(
          fullName: 'Updated',
          phoneNumber: '0901234567',
          schoolId: 's1',
          areaId: 'a1',
        );
        final json = req.toJson();

        expect(json['fullName'], 'Updated');
        expect(json['phoneNumber'], '0901234567');
        expect(json['schoolId'], 's1');
        expect(json['areaId'], 'a1');
      });
    });
  });

  // =========================================================================
  // 7. Listing DTO parsing (with enums)
  // =========================================================================
  group('Listing DTOs', () {
    group('ListingSummaryDto', () {
      test('fromJson parses rent listing correctly', () {
        final json = {
          'id': 'listing-1',
          'title': 'Máy tính xách tay Dell',
          'coverImageUrl': 'https://example.com/laptop.jpg',
          'listingType': 'Rent',
          'status': 'Available',
          'pricePerDay': 50000.0,
          'depositAmount': 200000.0,
          'categoryName': 'Điện tử',
          'schoolName': 'Đại học Bách Khoa',
          'areaName': 'Quận 10',
          'upvoteCount': 15,
          'commentCount': 3,
          'createdAt': '2025-06-15T10:30:00Z',
        };

        final listing = ListingSummaryDto.fromJson(json);

        expect(listing.id, 'listing-1');
        expect(listing.title, 'Máy tính xách tay Dell');
        expect(listing.listingType, ListingType.rent);
        expect(listing.status, ListingStatus.available);
        expect(listing.pricePerDay, 50000.0);
        expect(listing.depositAmount, 200000.0);
        expect(listing.categoryName, 'Điện tử');
        expect(listing.upvoteCount, 15);
        expect(listing.commentCount, 3);
        expect(listing.createdAt, isA<DateTime>());
        expect(listing.owner, isNull); // No owner in this json
      });

      test('fromJson parses borrow listing correctly', () {
        final json = {
          'id': 'listing-2',
          'title': 'Sách giáo trình',
          'listingType': 'Borrow',
          'status': 'Available',
          'pricePerDay': 0.0,
          'depositAmount': 50000.0,
          'upvoteCount': 5,
          'commentCount': 1,
          'createdAt': '2025-06-20T08:00:00Z',
        };

        final listing = ListingSummaryDto.fromJson(json);

        expect(listing.listingType, ListingType.borrow);
        expect(listing.pricePerDay, 0);
      });

      test('fromJson parses listing with owner', () {
        final json = {
          'id': 'listing-3',
          'title': 'Máy ảnh Canon',
          'listingType': 'Rent',
          'status': 'Available',
          'pricePerDay': 100000.0,
          'depositAmount': 500000.0,
          'owner': {
            'id': 'owner-1',
            'fullName': 'Nguyen Van B',
            'reputationScore': 90.0,
            'totalReviews': 8,
          },
          'upvoteCount': 20,
          'commentCount': 5,
          'createdAt': '2025-06-18T12:00:00Z',
        };

        final listing = ListingSummaryDto.fromJson(json);

        expect(listing.owner, isA<UserSummaryDto>());
        expect(listing.owner!.fullName, 'Nguyen Van B');
        expect(listing.owner!.reputationScore, 90.0);
      });

      test('toJson produces correct map', () {
        final listing = ListingSummaryDto(
          id: 'l1',
          title: 'Test',
          listingType: ListingType.rent,
          status: ListingStatus.available,
          pricePerDay: 10000,
          depositAmount: 50000,
          categoryName: 'Điện tử',
          upvoteCount: 0,
          commentCount: 0,
          createdAt: DateTime(2025, 6, 15),
        );

        final json = listing.toJson();
        expect(json['id'], 'l1');
        expect(json['title'], 'Test');
        expect(json['listingType'], 'Rent');
        expect(json['status'], 'Available');
        expect(json['pricePerDay'], 10000);
      });
    });

    group('ListingDetailDto', () {
      test('fromJson parses detail with nested objects', () {
        final json = {
          'id': 'listing-1',
          'title': 'MacBook Pro',
          'description': 'Like new condition',
          'listingType': 'Rent',
          'status': 'Available',
          'pricePerDay': 200000.0,
          'depositAmount': 1000000.0,
          'conditionNote': 'Còn mới 99%',
          'category': {
            'id': 'cat-1',
            'name': 'Điện tử',
            'slug': 'dien-tu',
            'icon': 'laptop',
          },
          'school': {'id': 'school-1', 'name': 'Đại học Bách Khoa'},
          'area': {'id': 'area-1', 'name': 'Quận 10', 'city': 'Hồ Chí Minh'},
          'tags': ['laptop', 'dell', 'macbook'],
          'images': [
            {
              'id': 'img-1',
              'imageUrl': 'https://example.com/img1.jpg',
              'isCover': true,
              'displayOrder': 0,
            },
          ],
          'owner': {
            'id': 'owner-1',
            'fullName': 'Nguyen Van C',
            'reputationScore': 85.0,
            'totalReviews': 15,
          },
          'viewCount': 150,
          'upvoteCount': 25,
          'commentCount': 8,
          'createdAt': '2025-06-10T09:00:00Z',
          'updatedAt': '2025-06-12T14:00:00Z',
        };

        final detail = ListingDetailDto.fromJson(json);

        expect(detail.id, 'listing-1');
        expect(detail.title, 'MacBook Pro');
        expect(detail.description, 'Like new condition');
        expect(detail.listingType, ListingType.rent);
        expect(detail.status, ListingStatus.available);
        expect(detail.conditionNote, 'Còn mới 99%');

        // Nested category
        expect(detail.category, isA<CategoryDto>());
        expect(detail.category!.name, 'Điện tử');

        // Nested school
        expect(detail.school, isA<SchoolDto>());
        expect(detail.school!.name, 'Đại học Bách Khoa');

        // Nested area with city
        expect(detail.area, isA<AreaDto>());
        expect(detail.area!.city, 'Hồ Chí Minh');

        // Tags
        expect(detail.tags, ['laptop', 'dell', 'macbook']);

        // Images
        expect(detail.images, hasLength(1));
        expect(detail.images![0], isA<ListingImageDto>());
        expect(detail.images![0].isCover, isTrue);

        // Owner
        expect(detail.owner, isA<UserSummaryDto>());
        expect(detail.owner!.fullName, 'Nguyen Van C');

        // Stats
        expect(detail.viewCount, 150);
        expect(detail.upvoteCount, 25);
        expect(detail.commentCount, 8);
        expect(detail.createdAt, isA<DateTime>());
        expect(detail.updatedAt, isA<DateTime>());
      });

      test('fromJson parses detail without optional fields', () {
        final json = {
          'id': 'listing-min',
          'title': 'Minimal Listing',
          'description': 'No extras',
          'listingType': 'Borrow',
          'status': 'Available',
          'pricePerDay': 0.0,
          'depositAmount': 0.0,
          'viewCount': 5,
          'upvoteCount': 0,
          'commentCount': 0,
          'createdAt': '2025-06-22T00:00:00Z',
        };

        final detail = ListingDetailDto.fromJson(json);

        expect(detail.conditionNote, isNull);
        expect(detail.category, isNull);
        expect(detail.school, isNull);
        expect(detail.area, isNull);
        expect(detail.tags, isNull);
        expect(detail.images, isNull);
        expect(detail.owner, isNull);
        expect(detail.updatedAt, isNull);
      });
    });
  });

  // =========================================================================
  // 8. Reference DTO parsing
  // =========================================================================
  group('Reference DTOs', () {
    group('CategoryDto', () {
      test('fromJson parses fully', () {
        final json = {
          'id': 'cat-1',
          'name': 'Điện tử',
          'slug': 'dien-tu',
          'icon': 'laptop',
        };
        final dto = CategoryDto.fromJson(json);
        expect(dto.id, 'cat-1');
        expect(dto.name, 'Điện tử');
        expect(dto.slug, 'dien-tu');
        expect(dto.icon, 'laptop');
      });

      test('fromJson without optional fields', () {
        final json = {'id': 'cat-2', 'name': 'Sách'};
        final dto = CategoryDto.fromJson(json);
        expect(dto.slug, isNull);
        expect(dto.icon, isNull);
      });
    });

    group('SchoolDto', () {
      test('fromJson parses correctly', () {
        final json = {
          'id': 'school-1',
          'name': 'Đại học Bách Khoa',
          'slug': 'dh-bach-khoa',
        };
        final dto = SchoolDto.fromJson(json);
        expect(dto.name, 'Đại học Bách Khoa');
        expect(dto.slug, 'dh-bach-khoa');
      });
    });

    group('AreaDto', () {
      test('fromJson parses with city', () {
        final json = {
          'id': 'area-1',
          'name': 'Quận 10',
          'city': 'Hồ Chí Minh',
        };
        final dto = AreaDto.fromJson(json);
        expect(dto.name, 'Quận 10');
        expect(dto.city, 'Hồ Chí Minh');
      });

      test('fromJson parses without city', () {
        final json = {'id': 'area-2', 'name': 'Trung tâm'};
        final dto = AreaDto.fromJson(json);
        expect(dto.city, isNull);
      });
    });

    group('TagDto', () {
      test('fromJson parses correctly', () {
        final json = {'id': 'tag-1', 'name': 'laptop', 'slug': 'laptop'};
        final dto = TagDto.fromJson(json);
        expect(dto.name, 'laptop');
        expect(dto.slug, 'laptop');
      });
    });
  });

  // =========================================================================
  // 9. Image DTO parsing
  // =========================================================================
  group('ListingImageDto', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'img-1',
        'imageUrl': 'https://example.com/img.jpg',
        'isCover': true,
        'displayOrder': 0,
      };

      final dto = ListingImageDto.fromJson(json);

      expect(dto.id, 'img-1');
      expect(dto.imageUrl, 'https://example.com/img.jpg');
      expect(dto.isCover, isTrue);
      expect(dto.displayOrder, 0);
    });
  });

  // =========================================================================
  // 10. Rental/Deposit DTO parsing (with enums)
  // =========================================================================
  group('Rental DTOs', () {
    group('RentalRequestDto', () {
      test('fromJson parses correctly', () {
        final json = {
          'id': 'req-1',
          'listingId': 'listing-1',
          'listingTitle': 'MacBook Pro',
          'status': 'Pending',
          'startDate': '2025-07-01',
          'endDate': '2025-07-07',
          'totalPrice': 1400000.0,
          'depositAmount': 1000000.0,
          'depositStatus': 'Pending',
          'message': 'Cần mượn gấp',
          'createdAt': '2025-06-20T10:00:00Z',
          'updatedAt': '2025-06-21T15:00:00Z',
        };

        final dto = RentalRequestDto.fromJson(json);

        expect(dto.id, 'req-1');
        expect(dto.status, RentalRequestStatus.pending);
        expect(dto.totalPrice, 1400000.0);
        expect(dto.depositStatus, DepositStatus.pending);
        expect(dto.message, 'Cần mượn gấp');
        expect(dto.startDate, DateTime.parse('2025-07-01'));
      });
    });

    group('RentalRequestDetailDto', () {
      test('fromJson parses flat detail fields', () {
        final json = {
          'id': 'req-1',
          'listingId': 'listing-1',
          'listingTitle': 'MacBook Pro',
          'listingImageUrl': 'https://example.com/img.jpg',
          'listingPricePerDay': 200000.0,
          'listingType': 'Rent',
          'status': 'Accepted',
          'startDate': '2025-07-01',
          'endDate': '2025-07-03',
          'totalPrice': 600000.0,
          'depositAmount': 1000000.0,
          'message': 'Cần gấp',
          'ownerId': 'owner-1',
          'ownerName': 'Nguyen Van A',
          'requesterId': 'req-user-1',
          'requesterName': 'Tran Van B',
          'createdAt': '2025-06-20T10:00:00Z',
          'updatedAt': '2025-06-20T12:00:00Z',
        };

        final dto = RentalRequestDetailDto.fromJson(json);

        expect(dto.id, 'req-1');
        expect(dto.status, 'Accepted');
        expect(dto.listingType, 'Rent');
        expect(dto.ownerName, 'Nguyen Van A');
        expect(dto.requesterName, 'Tran Van B');
        expect(dto.totalPrice, 600000.0);
        expect(dto.depositAmount, 1000000.0);
        expect(dto.message, 'Cần gấp');
        expect(dto.startDate, DateTime.parse('2025-07-01'));
      });
    });
  });

  // =========================================================================
  // 11. Review DTO parsing
  // =========================================================================
  group('ReviewDto', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'rev-1',
        'rentalRequestId': 'req-1',
        'reviewerId': 'user-1',
        'reviewerName': 'Nguyen Van A',
        'rating': 5,
        'comment': 'Rất tốt, đồ dùng như mới',
        'reputationDelta': 5.0,
        'createdAt': '2025-07-10T08:00:00Z',
      };

      final review = ReviewDto.fromJson(json);

      expect(review.id, 'rev-1');
      expect(review.rating, 5);
      expect(review.comment, 'Rất tốt, đồ dùng như mới');
      expect(review.reputationDelta, 5.0);
      expect(review.reviewerName, 'Nguyen Van A');
    });

    test('fromJson parses review without comment', () {
      final json = {
        'id': 'rev-2',
        'rentalRequestId': 'req-2',
        'reviewerId': 'user-2',
        'reviewerName': 'Tran Van B',
        'rating': 3,
        'reputationDelta': -2.0,
        'createdAt': '2025-07-11T10:00:00Z',
      };

      final review = ReviewDto.fromJson(json);
      expect(review.comment, isNull);
      expect(review.reputationDelta, -2.0);
    });
  });

  // =========================================================================
  // 12. Notification DTO parsing (with enum)
  // =========================================================================
  group('NotificationDto', () {
    test('fromJson parses correctly with referenceId and referenceType', () {
      final json = {
        'id': 'noti-1',
        'type': 'RentalRequest',
        'title': 'Yêu cầu thuê mới',
        'body': 'Nguyen Van A muốn thuê MacBook Pro của bạn',
        'referenceId': 'req-1',
        'referenceType': 'RentalRequest',
        'isRead': false,
        'createdAt': '2025-07-01T10:00:00Z',
      };

      final noti = NotificationDto.fromJson(json);

      expect(noti.id, 'noti-1');
      expect(noti.type, NotificationType.rentalRequest);
      expect(noti.title, 'Yêu cầu thuê mới');
      expect(noti.isRead, isFalse);
      expect(noti.referenceId, 'req-1');
      expect(noti.referenceType, 'RentalRequest');
    });

    test('fromJson parses read notification', () {
      final json = {
        'id': 'noti-2',
        'type': 'Message',
        'title': 'Tin nhắn mới',
        'body': 'Bạn có tin nhắn từ Tran Van B',
        'referenceId': 'conv-1',
        'isRead': true,
        'createdAt': '2025-07-02T09:00:00Z',
      };

      final noti = NotificationDto.fromJson(json);

      expect(noti.type, NotificationType.message);
      expect(noti.isRead, isTrue);
      expect(noti.referenceId, 'conv-1');
      expect(noti.referenceType, isNull);
    });
  });
}
