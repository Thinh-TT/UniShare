import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Wrapper for single-object API responses.
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final T? data;
  final String? message;

  const ApiResponse({this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

/// Wrapper for paginated list API responses.
///
/// The backend computes [totalPages] as a getter (not serialized), so it
/// may be absent from JSON. Use [hasMore] to check if there is a next page.
@JsonSerializable(genericArgumentFactories: true)
class PagedResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;

  @JsonKey(name: 'totalPages')
  final int? totalPages;

  const PagedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    this.totalPages,
  });

  /// Whether more items are available on the next page.
  bool get hasMore => page * pageSize < totalItems;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PagedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PagedResponseToJson(this, toJsonT);
}

/// ProblemDetails-compatible error response from backend.
@JsonSerializable()
class ProblemDetails {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final Map<String, List<String>>? errors;

  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.errors,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemDetailsToJson(this);
}
