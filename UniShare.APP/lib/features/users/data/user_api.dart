import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/user_profile_dto.dart';
import '../models/update_profile_request.dart';

/// Low-level API calls for user profile operations.
class UserApi {
  final ApiClient _apiClient;

  UserApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch the currently authenticated user's profile.
  Future<UserProfileDto> getMyProfile() async {
    final response = await _apiClient.getRaw(path: ApiEndpoints.myProfile);
    return UserProfileDto.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  /// Update the currently authenticated user's profile.
  Future<UserProfileDto> updateProfile(UpdateProfileRequest request) async {
    final response = await _apiClient.putRaw(
      path: ApiEndpoints.myProfile,
      data: request.toJson(),
    );
    return UserProfileDto.fromJson(
        response['data'] as Map<String, dynamic>);
  }
}
