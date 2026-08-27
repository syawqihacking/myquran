import 'dart:async';

import 'package:http/http.dart' as http;

import 'http_result.dart';

/// A thin wrapper around [http.Client] that adds configurable timeout,
/// exponential-backoff retries, and consistent [HttpResult] error handling.
///
/// Only transient failures are retried:
///   - Socket / connection errors
///   - Request timeouts
///   - Server errors (5xx status codes)
///
/// Client errors (4xx) are **not** retried.
class AppHttpClient {
  AppHttpClient({
    http.Client? innerClient,
    Duration? timeout,
    int? maxRetries,
  })  : _client = innerClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 10),
        _maxRetries = maxRetries ?? 3;

  final http.Client _client;
  final Duration _timeout;
  final int _maxRetries;

  // -- Convenience methods ---------------------------------------------------

  Future<HttpResult<String>> get(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      _sendWithRetry('GET', url, headers: headers);

  Future<HttpResult<String>> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _sendWithRetry('POST', url, headers: headers, body: body);

  Future<HttpResult<String>> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _sendWithRetry('PUT', url, headers: headers, body: body);

  Future<HttpResult<String>> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _sendWithRetry('DELETE', url, headers: headers, body: body);

  // -- Core request logic ----------------------------------------------------

  Future<HttpResult<String>> _sendWithRetry(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    int attempt = 0;

    while (true) {
      attempt++;
      try {
        final request = http.Request(method, url)..headers.addAll(headers ?? {});
        if (body != null) {
          request.body = body is String ? body : body.toString();
        }

        final streamedResponse = await _client
            .send(request)
            .timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return HttpSuccess(
            body: response.body,
            statusCode: response.statusCode,
          );
        }

        // 5xx — transient server error, worth retrying.
        if (response.statusCode >= 500 && attempt <= _maxRetries) {
          await _backoff(attempt);
          continue;
        }

        // 4xx — client error, do NOT retry.
        return HttpError(
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      } on TimeoutException {
        if (attempt <= _maxRetries) {
          await _backoff(attempt);
          continue;
        }
        return const HttpError(message: 'Request timed out');
      } on http.ClientException {
        if (attempt <= _maxRetries) {
          await _backoff(attempt);
          continue;
        }
        return const HttpError(message: 'Connection failed');
      } on Exception catch (e) {
        return HttpError(
          message: 'Request failed: $e',
          exception: e,
        );
      }
    }
  }

  /// Exponential backoff: 1 s, 2 s, 4 s …
  static Future<void> _backoff(int attempt) async {
    final delayMs = (1000 * (1 << (attempt - 1))).clamp(1000, 16000);
    await Future<void>.delayed(Duration(milliseconds: delayMs));
  }

  /// Releases the underlying HTTP client resources.
  void close() => _client.close();
}
