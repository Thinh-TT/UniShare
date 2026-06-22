import 'package:json_annotation/json_annotation.dart';
import '../../users/models/user_profile_dto.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserProfileDto user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
