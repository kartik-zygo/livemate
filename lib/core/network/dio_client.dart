import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import 'api_exception.dart';
import 'api_log_interceptor.dart';
import 'auth_interceptor.dart';

/// The single configured Dio instance. Providers own the paths; this owns the
/// base URL, timeouts, auth header injection and error translation.
class DioClient {
  DioClient({
    required TokenProvider tokenProvider,
    required TokenRefresher onRefresh,
    SessionExpiredCallback? onSessionExpired,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: const {'Accept': 'application/json'},
        // 204 No Content is a success on DELETE, and Dio should not treat any
        // 2xx/3xx as an error.
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: tokenProvider,
        onRefresh: onRefresh,
        onSessionExpired: onSessionExpired,
      ),
    );

    // Added after the auth interceptor so the log shows the request exactly as
    // it goes out, Authorization header and all.
    if (kDebugMode) {
      dio.interceptors.add(ApiLogInterceptor());
    }
  }

  late final Dio dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) => _guard(
    () => dio.get<T>(
      path,
      queryParameters: query,
      options: Options(extra: {'skipAuth': skipAuth}),
    ),
  );

  Future<T> post<T>(String path, {Object? body}) =>
      _guard(() => dio.post<T>(path, data: body));

  Future<T> patch<T>(String path, {Object? body}) =>
      _guard(() => dio.patch<T>(path, data: body));

  Future<void> delete(String path) async {
    await _guardRaw(() => dio.delete<dynamic>(path));
  }

  Future<T> upload<T>(String path, FormData form) =>
      _guard(() => dio.post<T>(path, data: form));

  /// Hits `GET /health`, which lives at the server root rather than under
  /// `/api/v1`.
  Future<bool> healthy() async {
    try {
      final res = await dio.get<dynamic>(
        '${Env.serverRoot}/health',
        options: Options(extra: const {'skipAuth': true}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<T> _guard<T>(Future<Response<T>> Function() run) async {
    final response = await _guardRaw(run);
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'The server returned an empty response.',
      );
    }
    return data;
  }

  Future<Response<T>> _guardRaw<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
