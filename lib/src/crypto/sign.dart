import '../types/api_types.dart';
import 'sha256.dart';
import 'hmac.dart';

/// Create an HMAC-SHA256 signature for a T1Y API request.
///
/// The message format is (each line separated by \n):
///   1. HTTP method (uppercase)
///   2. URL path + query string
///   3. SHA-256 hex digest of the request body
///   4. Application ID (as string)
///   5. Unix timestamp (as string)
///
/// Returns 64-character hex-encoded HMAC-SHA256 signature.
String createSignature(SignatureInput input) {
  final bodyHash = sha256Hex(input.body);

  final message = [
    input.method.toUpperCase(),
    input.pathAndQuery,
    bodyHash,
    input.appId.toString(),
    input.timestamp.toString(),
  ].join('\n');

  return hmacSHA256Hex(input.secretKey, message);
}

/// Get the current UTC Unix timestamp adjusted by the given offset.
///
/// Returns 10-digit Unix timestamp string.
String getSafeTimestamp(int offset) {
  final now = DateTime.now().toUtc();
  final unix = (now.millisecondsSinceEpoch / 1000).floor() + offset;
  return unix.toString();
}
