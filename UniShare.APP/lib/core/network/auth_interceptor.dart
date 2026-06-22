import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import 'token_storage.dart';
import '../constants/api_endpoints.dart';

/// Dio interceptor that attaches JWT Bearer tokens and handles 401 refresh.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final AppConfig _appConfig;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _pendingRequests = [];

  AuthInterceptor({
    required TokenStorage tokenStorage,
    required AppConfig appConfig,
    required Dio dio,
  })  : _tokenStorage = tokenStorage,
        _appConfig = appConfig,
        _dio = dio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid infinite loop if refresh itself fails with 401
    if (err.requestOptions.path == ApiEndpoints.refreshToken) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue this request until refresh completes
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _isRefreshing = false;
        await _tokenStorage.clearTokens();
        return handler.next(err);
      }

      // Call refresh token endpoint without this interceptor
      final response = await Dio(BaseOptions(
        baseUrl: _appConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )).post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data?['data'];
      if (data == null) throw Exception('Invalid refresh response');

      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'] ?? refreshToken,
      );

      // Retry the original request with new token
      final newToken = data['accessToken'];
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Retry all queued requests
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newToken';
        _dio.fetch(pending.options).then(
          (r) => pending.handler.resolve(r),
          onError: (e) =>
              pending.handler.reject(e as DioException),
        );
      }
    } catch (e) {
      // Refresh failed — clear tokens and reject everything
      await _tokenStorage.clearTokens();
      handler.next(err);
      for (final pending in _pendingRequests) {
        pending.handler.next(
          DioException(
            requestOptions: pending.options,
            response: Response(
              requestOptions: pending.options,
              statusCode: 401,
            ),
          ),
        );
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
}
