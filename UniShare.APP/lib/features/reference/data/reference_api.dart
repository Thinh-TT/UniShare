import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/school_dto.dart';
import '../models/area_dto.dart';

/// Low-level API calls for reference data (schools, areas, categories, tags).
class ReferenceApi {
  final ApiClient _apiClient;

  ReferenceApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch all schools.
  Future<List<SchoolDto>> getSchools() async {
    final response = await _apiClient.getRaw(path: ApiEndpoints.schools);
    final list = response['data'] as List<dynamic>;
    return list
        .map((e) => SchoolDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all areas.
  Future<List<AreaDto>> getAreas() async {
    final response = await _apiClient.getRaw(path: ApiEndpoints.areas);
    final list = response['data'] as List<dynamic>;
    return list
        .map((e) => AreaDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
