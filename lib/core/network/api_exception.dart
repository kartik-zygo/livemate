import 'dart:io';

import 'package:dio/dio.dart';

/// Everything above the provider layer speaks in [ApiException] rather than
/// [DioException], so controllers never have to know Dio exists.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.messages = const [],
    this.kind = ApiErrorKind.unknown,
  });

  /// A single line fit to show the user.
  final String message;

  /// NestJS validation failures arrive as a list; keep them all so a form can
  /// show every field error at once.
  final List<String> messages;

  final int? statusCode;
  final ApiErrorKind kind;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => statusCode == 400 || statusCode == 422;
  bool get isNetwork => kind == ApiErrorKind.network;

  /// Maps a Dio failure onto the NestJS error envelope:
  /// `{ statusCode, message: String | List<String>, error }`.
  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'The server took too long to respond. Please try again.',
          kind: ApiErrorKind.timeout,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request cancelled.',
          kind: ApiErrorKind.cancelled,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (e.error is SocketException ||
            e.type == DioExceptionType.connectionError) {
          return const ApiException(
            message: 'No connection. Check your network and try again.',
            kind: ApiErrorKind.network,
          );
        }
        return ApiException(
          message: e.message ?? 'Something went wrong. Please try again.',
        );
      case DioExceptionType.transformTimeout:
        return const ApiException(
          message: 'That response took too long to process.',
          kind: ApiErrorKind.timeout,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Could not establish a secure connection.',
          kind: ApiErrorKind.network,
        );
      case DioExceptionType.badResponse:
        return ApiException._fromResponse(e.response);
    }
  }

  factory ApiException._fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;

    final parsed = _extractMessages(data);
    final fallback = _defaultMessageFor(status);

    return ApiException(
      message: parsed.isEmpty ? fallback : parsed.first,
      messages: parsed,
      statusCode: status,
      kind: ApiErrorKind.server,
    );
  }

  /// `message` may be a String **or** a List of strings — handle both.
  static List<String> _extractMessages(Object? data) {
    if (data is Map) {
      final raw = data['message'] ?? data['error'];
      if (raw is String && raw.trim().isNotEmpty) return [raw.trim()];
      if (raw is List) {
        final items = raw
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
        if (items.isNotEmpty) return items;
      }
    }
    if (data is String && data.trim().isNotEmpty && data.length < 300) {
      return [data.trim()];
    }
    return const [];
  }

  static String _defaultMessageFor(int? status) => switch (status) {
    400 => 'That request was not valid.',
    401 => 'Your session has expired. Please sign in again.',
    403 => 'You do not have access to this.',
    404 => 'We could not find that.',
    409 => 'That conflicts with something that already exists.',
    413 => 'That file is too large.',
    429 => 'Too many requests. Please slow down.',
    _ when status != null && status >= 500 =>
      'The server had a problem. Please try again shortly.',
    _ => 'Something went wrong. Please try again.',
  };

  /// Wraps anything that is not already an [ApiException].
  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) return ApiException.fromDio(error);
    return ApiException(message: error.toString());
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

enum ApiErrorKind { network, timeout, server, cancelled, unknown }
