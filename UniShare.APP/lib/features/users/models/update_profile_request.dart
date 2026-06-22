import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? schoolId;
  final String? areaId;

  const UpdateProfileRequest({
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.schoolId,
    this.areaId,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
