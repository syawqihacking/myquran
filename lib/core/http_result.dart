/// Typed result wrapper for HTTP requests, avoiding exception-driven control
/// flow and making error handling explicit at every call site.
sealed class HttpResult<T> {
  const HttpResult();
}

/// A successful HTTP response.
class HttpSuccess<T> extends HttpResult<T> {
  const HttpSuccess({required this.body, required this.statusCode});

  /// The deserialised (or raw) response body.
  final T body;

  /// The HTTP status code (typically 200).
  final int statusCode;
}

/// An HTTP error — either a network/timeout failure or a non-successful
/// status code.
class HttpError extends HttpResult<Never> {
  const HttpError({
    required this.message,
    this.statusCode,
    this.exception,
  });

  /// Human-readable error description.
  final String message;

  /// HTTP status code, if the server actually responded (null for
  /// connection-level failures like timeouts).
  final int? statusCode;

  /// The underlying exception that caused this error, if any.
  final Object? exception;
}
