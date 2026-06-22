import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import 'api_response.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Centralized HTTP client wrapping Dio for all API calls.
class ApiClient {
  late final Dio _dio;

  ApiClient({
    required AppConfig appConfig,
    required TokenStorage tokenStorage,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: appConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    _dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        appConfig: appConfig,
        dio: _dio,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// Perform a GET request with optional query parameters.
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParams,
    );
    return ApiResponse.fromJson(response.data, (json) {
      if (json == null) return null as T;
      return fromJsonT(json as Map<String, dynamic>);
    });
  }

  /// Perform a GET request returning a paginated response.
  Future<PagedResponse<T>> getPaged<T>({
    required String path,
    Map<String, dynamic>? queryParams,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParams,
    );
    return PagedResponse.fromJson(response.data, (json) {
      return fromJsonT(json as Map<String, dynamic>);
    });
  }

  /// Perform a GET request returning raw JSON data.
  Future<Map<String, dynamic>> getRaw({
    required String path,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Perform a POST request with a JSON body.
  Future<ApiResponse<T>> post<T>({
    required String path,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final response = await _dio.post(path, data: data);
    return ApiResponse.fromJson(response.data, (json) {
      if (json == null) return null as T;
      return fromJsonT(json as Map<String, dynamic>);
    });
  }

  /// Perform a POST request returning raw JSON.
  Future<Map<String, dynamic>> postRaw({
    required String path,
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Perform a PUT request returning raw JSON.
  Future<Map<String, dynamic>> putRaw({
    required String path,
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.put(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Perform a PUT request with a JSON body.
  Future<ApiResponse<T>> put<T>({
    required String path,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final response = await _dio.put(path, data: data);
    return ApiResponse.fromJson(response.data, (json) {
      if (json == null) return null as T;
      return fromJsonT(json as Map<String, dynamic>);
    });
  }

  /// Perform a PATCH request with a JSON body.
  Future<ApiResponse<T>> patch<T>({
    required String path,
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final response = await _dio.patch(path, data: data);

    // Handle 204 No Content and other empty responses gracefully.
    // These return a String or null body that cannot be parsed as Map.
    if (response.data == null || response.data is! Map<String, dynamic>) {
      return ApiResponse<T>(data: null);
    }

    return ApiResponse.fromJson(response.data, (json) {
      if (json == null) return null as T;
      return fromJsonT(json as Map<String, dynamic>);
    });
  }

  /// Perform a DELETE request.
  Future<void> delete({
    required String path,
  }) async {
    await _dio.delete(path);
  }

  /// Perform a DELETE request returning raw JSON (e.g. upvote toggle).
  Future<Map<String, dynamic>> deleteRaw({
    required String path,
  }) async {
    final response = await _dio.delete(path);
    return response.data as Map<String, dynamic>;
  }

  /// Upload multipart form data (e.g. images).
  Future<ApiResponse<T>> postMultipart<T>({
    required String path,
    required FormData formData,
    required T Function(Map<String, dynamic>) fromJsonT,
  }) async {
    final response = await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return ApiResponse.fromJson(response.data, (json) {
      if (json == null) return null as T;
      return fromJsonT(json as Map<String, dynamic>);
    });
  }

  /// Upload multipart form data, returning raw JSON.
  /// Use when the response `data` field is a List (not a Map),
  /// e.g. ApiResponse<List<T>>.
  Future<Map<String, dynamic>> postMultipartRaw({
    required String path,
    required FormData formData,
  }) async {
    final response = await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data as Map<String, dynamic>;
  }
}
