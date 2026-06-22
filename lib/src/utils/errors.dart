/// Custom error class for t1yOS SDK errors.
/// Wraps API error responses with code, message, and data.
class T1YError implements Exception {
  /// HTTP status or error code
  final int code;

  /// Error message
  final String message;

  /// Response data from server (if any)
  final dynamic data;

  const T1YError(this.code, this.message, [this.data]);

  Map<String, dynamic> toJson() {
    return {
      'name': 'T1YError',
      'code': code,
      'message': message,
      'data': data,
    };
  }

  @override
  String toString() => 'T1YError($code): $message';
}

/// Validation error thrown when configuration parameters are invalid.
class ValidationError implements Exception {
  final String message;

  const ValidationError(this.message);

  @override
  String toString() => 'ValidationError: $message';
}
