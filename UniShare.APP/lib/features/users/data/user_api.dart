import 'package:dio/dio.dart';
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

  /// Upload or update the current user's avatar.
  ///
  /// [filePath] is the local path of the image file to upload.
  /// Returns the new avatar URL from the server.
  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _apiClient.postMultipartRaw(
      path: ApiEndpoints.uploadAvatar,
      formData: formData,
    );

    // Response: { data: { avatarUrl: "/uploads/avatars/xxx.jpg" } }
    final data = response['data'] as Map<String, dynamic>;
    return data['avatarUrl'] as String;
  }
}
