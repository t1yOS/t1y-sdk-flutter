import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../crypto/aes.dart';
import '../types/api_types.dart';
import '../utils/errors.dart';
import '../utils/time_utils.dart';

/// Process a raw HTTP Response into the SDK's standard ApiResponse format.
///
/// Handles:
/// 1. JSON parsing or string fallback
/// 2. Safe mode AES-GCM decryption (response data has `j` field)
/// 3. Timestamp formatting (createdAt/updatedAt → local time)
/// 4. Error wrapping for non-2xx status codes
Future<ApiResponse<T>> handleResponse<T>(
  http.Response response,
  bool isSafeMode,
  String secretKey,
  String timeFormat,
) async {
  // Parse response body
  dynamic rawData;
  final contentType = response.headers['content-type'] ?? '';
  final responseText = response.body;

  if (contentType.contains('application/json')) {
    try {
      rawData = jsonDecode(responseText);
    } catch (_) {
      rawData = responseText;
    }
  } else {
    rawData = responseText;
  }

  // If safe mode is on and the response data looks encrypted (has `j` field),
  // decrypt it first
  if (isSafeMode && rawData is Map && rawData.containsKey('j')) {
    try {
      final decrypted = decryptAESGCM(
        jsonEncode(rawData),
        Uint8List.fromList(utf8.encode(secretKey)),
      );

      // Try to parse decrypted result as JSON
      try {
        rawData = jsonDecode(decrypted);
      } catch (_) {
        rawData = decrypted;
      }
    } catch (err) {
      throw T1YError(
        400,
        'AES-256-GCM decryption failed',
        err is Exception ? err.toString() : null,
      );
    }
  }

  // If the response is a standard ApiResponse wrapper, format timestamps
  if (rawData is Map && rawData.containsKey('data')) {
    rawData['data'] = formatTimestampsToLocal(rawData['data'], timeFormat);

    final code = rawData['code'] as int? ?? response.statusCode;
    final message = rawData['message'] as String? ?? 'ok';
    final data = rawData['data'] as T? ?? rawData as T;

    // If the status code is not 2xx, throw a T1YError
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw T1YError(code, message, data);
    }

    return ApiResponse<T>(code: code, message: message, data: data);
  }

  // Handle non-standard responses
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw T1YError(response.statusCode, response.reasonPhrase ?? '', rawData);
  }

  // Raw success response — wrap in ApiResponse shape
  return ApiResponse<T>(
    code: 0,
    message: 'ok',
    data: formatTimestampsToLocal(rawData, timeFormat) as T,
  );
}

/// Handle fetch errors (network errors, timeouts, etc.)
Never handleFetchError(dynamic error) {
  if (error is T1YError) throw error;

  if (error is http.ClientException) {
    throw T1YError(0, error.message, null);
  }

  // Timeout
  if (error.toString().contains('TimeoutException') ||
      error.toString().contains('timed out')) {
    throw T1YError(408, 'Request timeout', null);
  }

  if (error is Exception) {
    throw T1YError(0, error.toString(), null);
  }

  throw T1YError(0, 'Unknown error', error);
}
