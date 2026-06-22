import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/reference_api.dart';
import '../../models/school_dto.dart';
import '../../models/area_dto.dart';
import '../../models/category_dto.dart';
import '../../models/tag_dto.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;

/// Provider for ReferenceApi singleton.
final referenceApiProvider = Provider<ReferenceApi>((ref) {
  return ReferenceApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for the list of schools.
final schoolsProvider = FutureProvider<List<SchoolDto>>((ref) async {
  return ref.read(referenceApiProvider).getSchools();
});

/// Provider for the list of areas.
final areasProvider = FutureProvider<List<AreaDto>>((ref) async {
  return ref.read(referenceApiProvider).getAreas();
});

/// Provider for the list of categories.
final categoriesProvider = FutureProvider<List<CategoryDto>>((ref) async {
  return ref.read(referenceApiProvider).getCategories();
});

/// Provider for the list of tags.
final tagsProvider = FutureProvider<List<TagDto>>((ref) async {
  return ref.read(referenceApiProvider).getTags();
});
