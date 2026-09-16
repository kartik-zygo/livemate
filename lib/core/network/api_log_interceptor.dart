import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only wire log: every request and every response, body included.
///
/// Dio's own [LogInterceptor] prints a payload as one long `toString()` line,
/// which Android's log buffer clips at roughly a thousand characters — so large
/// responses look empty or half-there. This one pretty-prints JSON and emits it
/// through [debugPrint], which throttles output so nothing gets dropped.
class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({this.showAuthToken = false});

  /// A full JWT is long and is a credential, so only its head is shown by
  /// default. Flip this to `true` when you need to paste one into curl.
  final bool showAuthToken;

  /// Where the request clock is parked, so the response can report a duration.
  static const String _startedAt = '__apiLogStart';

  static final JsonEncoder _pretty = JsonEncoder.withIndent(
    '  ',
    (Object? value) => value.toString(),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now();
    _emit([
      '→ ${options.method} ${options.uri}',
      ..._section('headers', _headerLines(options.headers)),
      ..._section('body', _bodyLines(options.data)),
    ]);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    _emit([
      '← ${response.statusCode} ${request.method} ${request.uri}'
          '${_elapsed(request)}',
      ..._section('headers', _responseHeaderLines(response.headers)),
      ..._section('data', _bodyLines(response.data)),
    ]);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final response = err.response;
    _emit([
      '✖ ${response?.statusCode ?? err.type.name} ${request.method} '
          '${request.uri}${_elapsed(request)}',
      '  error: ${err.message ?? err}',
      if (response != null) ..._section('data', _bodyLines(response.data)),
    ]);
    handler.next(err);
  }

  // ── Formatting ─────────────────────────────────────────────────────────

  Iterable<String> _headerLines(Map<String, dynamic> headers) sync* {
    for (final entry in headers.entries) {
      final value = '${entry.value}';
      final isAuth = entry.key.toLowerCase() == 'authorization';
      yield '${entry.key}: ${isAuth && !showAuthToken ? _mask(value) : value}';
    }
  }

  Iterable<String> _responseHeaderLines(Headers headers) sync* {
    for (final entry in headers.map.entries) {
      yield '${entry.key}: ${entry.value.join(', ')}';
    }
  }

  /// Bodies that are not text — uploads, byte lists, streams — are described
  /// rather than dumped, so a photo upload does not fill the console.
  Iterable<String> _bodyLines(Object? data) {
    if (data == null) return const [];
    if (data is FormData) {
      return [
        for (final field in data.fields) '${field.key}: ${field.value}',
        for (final file in data.files)
          '${file.key}: <${file.value.filename ?? 'file'}, '
              '${file.value.length} bytes>',
      ];
    }
    if (data is List<int>) return ['<${data.length} bytes>'];
    if (data is Stream) return const ['<stream>'];
    return const LineSplitter().convert(_encode(data));
  }

  String _encode(Object? data) {
    if (data is String) {
      if (data.isEmpty) return '<empty>';
      // A plain-text response type still usually carries JSON; render it as
      // JSON when it parses, and verbatim when it does not.
      try {
        return _pretty.convert(jsonDecode(data));
      } catch (_) {
        return data;
      }
    }
    try {
      return _pretty.convert(data);
    } catch (_) {
      return '$data';
    }
  }

  String _mask(String value) => value.length <= 24
      ? value
      : '${value.substring(0, 20)}… (${value.length} chars)';

  String _elapsed(RequestOptions options) {
    final start = options.extra[_startedAt];
    if (start is! DateTime) return '';
    return ' · ${DateTime.now().difference(start).inMilliseconds}ms';
  }

  Iterable<String> _section(String label, Iterable<String> lines) {
    final body = lines.toList();
    if (body.isEmpty) return const [];
    return ['  $label:', ...body.map((line) => '    $line')];
  }

  /// Only the summary line is tagged, so a JSON block stays clean to copy out
  /// of the console.
  void _emit(List<String> lines) {
    if (lines.isEmpty) return;
    debugPrint('[api] ${lines.first}');
    for (final line in lines.skip(1)) {
      debugPrint(line);
    }
  }
}
