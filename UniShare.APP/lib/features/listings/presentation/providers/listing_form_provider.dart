import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/listing_type.dart';
import '../../data/listings_repository.dart';
import '../../models/listing_detail_dto.dart';
import '../../models/create_listing_request.dart';
import '../../models/update_listing_request.dart';
import 'listings_provider.dart' show listingsRepositoryProvider;

/// State for the listing create/edit form.
class ListingFormState {
  // Form fields
  final String title;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String? schoolId;
  final String? schoolName;
  final String? areaId;
  final String? areaName;
  final ListingType listingType;
  final double pricePerDay;
  final double depositAmount;
  final String conditionNote;
  final List<String> tags;

  // UI state
  final bool isSubmitting;
  final bool isEditMode;
  final String? listingId;
  final String? errorMessage;
  final bool hasSubmitted;

  // Validation errors
  final String? titleError;
  final String? descriptionError;
  final String? categoryError;
  final String? priceError;
  final String? depositError;
  final String? conditionNoteError;
  final String? tagsError;

  const ListingFormState({
    this.title = '',
    this.description = '',
    this.categoryId,
    this.categoryName,
    this.schoolId,
    this.schoolName,
    this.areaId,
    this.areaName,
    this.listingType = ListingType.rent,
    this.pricePerDay = 0,
    this.depositAmount = 0,
    this.conditionNote = '',
    this.tags = const [],
    this.isSubmitting = false,
    this.isEditMode = false,
    this.listingId,
    this.errorMessage,
    this.hasSubmitted = false,
    this.titleError,
    this.descriptionError,
    this.categoryError,
    this.priceError,
    this.depositError,
    this.conditionNoteError,
    this.tagsError,
  });

  ListingFormState copyWith({
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    String? schoolId,
    String? schoolName,
    String? areaId,
    String? areaName,
    ListingType? listingType,
    double? pricePerDay,
    double? depositAmount,
    String? conditionNote,
    List<String>? tags,
    bool? isSubmitting,
    bool? isEditMode,
    String? listingId,
    String? errorMessage,
    bool? hasSubmitted,
    String? titleError,
    String? descriptionError,
    String? categoryError,
    String? priceError,
    String? depositError,
    String? conditionNoteError,
    String? tagsError,
    bool clearCategoryId = false,
    bool clearCategoryName = false,
    bool clearSchoolId = false,
    bool clearSchoolName = false,
    bool clearAreaId = false,
    bool clearAreaName = false,
    bool clearErrorMessage = false,
    bool clearTitleError = false,
    bool clearDescriptionError = false,
    bool clearCategoryError = false,
    bool clearPriceError = false,
    bool clearDepositError = false,
    bool clearConditionNoteError = false,
    bool clearTagsError = false,
  }) {
    return ListingFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId:
          clearCategoryId ? null : (categoryId ?? this.categoryId),
      categoryName:
          clearCategoryName ? null : (categoryName ?? this.categoryName),
      schoolId: clearSchoolId ? null : (schoolId ?? this.schoolId),
      schoolName:
          clearSchoolName ? null : (schoolName ?? this.schoolName),
      areaId: clearAreaId ? null : (areaId ?? this.areaId),
      areaName: clearAreaName ? null : (areaName ?? this.areaName),
      listingType: listingType ?? this.listingType,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      depositAmount: depositAmount ?? this.depositAmount,
      conditionNote: conditionNote ?? this.conditionNote,
      tags: tags ?? this.tags,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isEditMode: isEditMode ?? this.isEditMode,
      listingId: listingId ?? this.listingId,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      titleError:
          clearTitleError ? null : (titleError ?? this.titleError),
      descriptionError: clearDescriptionError
          ? null
          : (descriptionError ?? this.descriptionError),
      categoryError: clearCategoryError
          ? null
          : (categoryError ?? this.categoryError),
      priceError: clearPriceError ? null : (priceError ?? this.priceError),
      depositError:
          clearDepositError ? null : (depositError ?? this.depositError),
      conditionNoteError: clearConditionNoteError
          ? null
          : (conditionNoteError ?? this.conditionNoteError),
      tagsError: clearTagsError ? null : (tagsError ?? this.tagsError),
    );
  }
}

/// Notifier for the listing create/edit form.
class ListingFormNotifier extends StateNotifier<ListingFormState> {
  final ListingsRepository _repository;

  ListingFormNotifier(this._repository) : super(const ListingFormState());

  void setTitle(String v) =>
      state = state.copyWith(title: v, clearTitleError: true);

  void setDescription(String v) =>
      state = state.copyWith(description: v, clearDescriptionError: true);

  void setCategoryId(String? id, String? name) => state = state.copyWith(
        categoryId: id,
        categoryName: name,
        clearCategoryId: id == null,
        clearCategoryName: name == null,
        clearCategoryError: true,
      );

  void setSchoolId(String? id, String? name) => state = state.copyWith(
        schoolId: id,
        schoolName: name,
        clearSchoolId: id == null,
        clearSchoolName: name == null,
      );

  void setAreaId(String? id, String? name) => state = state.copyWith(
        areaId: id,
        areaName: name,
        clearAreaId: id == null,
        clearAreaName: name == null,
      );

  void setListingType(ListingType v) {
    if (v == ListingType.borrow) {
      state = state.copyWith(
        listingType: v,
        pricePerDay: 0,
        depositAmount: 0,
      );
    } else {
      state = state.copyWith(listingType: v);
    }
  }

  void setPricePerDay(double v) =>
      state = state.copyWith(pricePerDay: v, clearPriceError: true);
  void setDepositAmount(double v) =>
      state = state.copyWith(depositAmount: v, clearDepositError: true);
  void setConditionNote(String v) =>
      state = state.copyWith(conditionNote: v, clearConditionNoteError: true);

  void addTag(String t) {
    if (t.isEmpty || state.tags.contains(t)) return;
    state = state.copyWith(tags: [...state.tags, t], clearTagsError: true);
  }

  void removeTag(String t) =>
      state = state.copyWith(
          tags: state.tags.where((x) => x != t).toList(),
          clearTagsError: true);

  /// Pre-fill the form from an existing listing (edit mode).
  void loadExistingListing(ListingDetailDto listing) {
    state = ListingFormState(
      title: listing.title,
      description: listing.description,
      categoryId: listing.category?.id,
      categoryName: listing.category?.name,
      schoolId: listing.school?.id,
      schoolName: listing.school?.name,
      areaId: listing.area?.id,
      areaName: listing.area?.name,
      listingType: listing.listingType,
      pricePerDay: listing.pricePerDay,
      depositAmount: listing.depositAmount ?? 0,
      conditionNote: listing.conditionNote ?? '',
      tags: (listing.tags ?? []).map((t) => t.name).toList(),
      isEditMode: true,
      listingId: listing.id,
    );
  }

  /// Reset the form to empty (create mode).
  void reset() {
    state = const ListingFormState();
  }

  /// Validate all fields. Returns true if valid.
  bool validate() {
    final trimmedTitle = state.title.trim();
    final trimmedDesc = state.description.trim();

    // Title
    String? titleError;
    if (trimmedTitle.isEmpty) {
      titleError = 'Vui lòng nhập tiêu đề';
    } else if (trimmedTitle.length < 5) {
      titleError = 'Tiêu đề phải có ít nhất 5 ký tự';
    } else if (trimmedTitle.length > 200) {
      titleError = 'Tiêu đề không được vượt quá 200 ký tự';
    }

    // Description
    String? descriptionError;
    if (trimmedDesc.isEmpty) {
      descriptionError = 'Vui lòng nhập mô tả';
    } else if (trimmedDesc.length < 20) {
      descriptionError = 'Mô tả phải có ít nhất 20 ký tự';
    } else if (trimmedDesc.length > 2000) {
      descriptionError = 'Mô tả không được vượt quá 2000 ký tự';
    }

    // Category
    final categoryError =
        state.categoryId == null ? 'Vui lòng chọn danh mục' : null;

    // Price
    String? priceError;
    if (state.listingType == ListingType.rent) {
      if (state.pricePerDay <= 0) {
        priceError = 'Vui lòng nhập giá cho thuê lớn hơn 0';
      }
    }

    // Deposit
    String? depositError;
    if (state.depositAmount < 0) {
      depositError = 'Tiền cọc không được âm';
    }

    // Condition note
    String? conditionNoteError;
    if (state.conditionNote.length > 500) {
      conditionNoteError = 'Ghi chú tình trạng không được vượt quá 500 ký tự';
    }

    // Tags
    String? tagsError;
    if (state.tags.length > 10) {
      tagsError = 'Tối đa 10 thẻ tag';
    } else {
      for (final t in state.tags) {
        if (t.length < 2) {
          tagsError = 'Mỗi tag phải có ít nhất 2 ký tự';
          break;
        }
        if (t.length > 50) {
          tagsError = 'Mỗi tag không được vượt quá 50 ký tự';
          break;
        }
      }
    }

    state = state.copyWith(
      titleError: titleError,
      descriptionError: descriptionError,
      categoryError: categoryError,
      priceError: priceError,
      depositError: depositError,
      conditionNoteError: conditionNoteError,
      tagsError: tagsError,
      hasSubmitted: true,
    );

    return titleError == null &&
        descriptionError == null &&
        categoryError == null &&
        priceError == null &&
        depositError == null &&
        conditionNoteError == null &&
        tagsError == null;
  }

  /// Submit the form. Returns the created/updated listing ID on success, or null on failure.
  Future<String?> submit() async {
    if (!validate()) return null;

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    // ignore: unused_label
    try {
      if (state.isEditMode && state.listingId != null) {
        final request = UpdateListingRequest(
          title: state.title.trim(),
          description: state.description.trim(),
          categoryId: state.categoryId!,
          schoolId: state.schoolId,
          areaId: state.areaId,
          listingType: state.listingType,
          pricePerDay: state.pricePerDay,
          depositAmount: state.depositAmount,
          conditionNote:
              state.conditionNote.isEmpty ? null : state.conditionNote.trim(),
          tags: state.tags.isEmpty ? null : state.tags,
        );
        final result =
            await _repository.updateListing(state.listingId!, request);
        state = state.copyWith(isSubmitting: false);
        return result.id;
      } else {
        final request = CreateListingRequest(
          title: state.title.trim(),
          description: state.description.trim(),
          categoryId: state.categoryId!,
          schoolId: state.schoolId,
          areaId: state.areaId,
          listingType: state.listingType,
          pricePerDay: state.pricePerDay,
          depositAmount: state.depositAmount,
          conditionNote:
              state.conditionNote.isEmpty ? null : state.conditionNote.trim(),
          tags: state.tags.isEmpty ? null : state.tags,
        );
        final result = await _repository.createListing(request);
        state = state.copyWith(isSubmitting: false);
        return result.id;
      }
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Không thể lưu bài đăng. ${e.toString()}',
      );
      return null;
    }
  }
}

/// Provider for the listing create/edit form.
final listingFormProvider =
    StateNotifierProvider<ListingFormNotifier, ListingFormState>((ref) {
  return ListingFormNotifier(ref.read(listingsRepositoryProvider));
});
