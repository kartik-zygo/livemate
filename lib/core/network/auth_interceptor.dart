import 'package:dio/dio.dart';

/// Supplies the current Supabase access token. Kept as a callback rather than a
/// direct AuthService reference so the network layer stays free of app-level
/// dependencies (and so tests can hand in a fixed token).
typedef TokenProvider = String? Function();

/// Asks Supabase to refresh and returns the fresh token, or null if the session
/// is truly gone.
typedef TokenRefresher = Future<String?> Function();

/// Called once when a request is rejected with 401 even after a refresh.
typedef SessionExpiredCallback = void Function();

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenProvider tokenProvider,
    required TokenRefresher onRefresh,
    this.onSessionExpired,
  }) : _token = tokenProvider,
       _refresh = onRefresh;

  final TokenProvider _token;
  final TokenRefresher _refresh;
  final SessionExpiredCallback? onSessionExpired;

  /// Guards against a refresh storm when several requests 401 at once.
  bool _refreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] != true) {
      final token = _token();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried =
        err.requestOptions.extra['retriedAfterRefresh'] == true;

    if (!is401 ||
        alreadyRetried ||
        err.requestOptions.extra['skipAuth'] == true) {
      return handler.next(err);
    }

    if (_refreshing) return handler.next(err);

    _refreshing = true;
    String? fresh;
    try {
      fresh = await _refresh();
    } catch (_) {
      fresh = null;
    } finally {
      _refreshing = false;
    }

    if (fresh == null || fresh.isEmpty) {
      onSessionExpired?.call();
      return handler.next(err);
    }

    // Replay the original request once with the new token.
    final options = err.requestOptions
      ..headers['Authorization'] = 'Bearer $fresh'
      ..extra['retriedAfterRefresh'] = true;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: options.baseUrl,
          connectTimeout: options.connectTimeout,
          receiveTimeout: options.receiveTimeout,
        ),
      );
      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) onSessionExpired?.call();
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }
}
