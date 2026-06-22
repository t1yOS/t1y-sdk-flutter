import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../crypto/aes.dart';
import '../crypto/sign.dart';
import '../types/client_types.dart';
import '../types/api_types.dart';
import '../utils/constants.dart';
import '../utils/convert.dart';
import '../utils/url_utils.dart';
import 'response.dart';

/// Options for a single HTTP request.
class RequestOptions {
  final HttpMethod method;
  final String path;
  final dynamic params;
  final bool? encryption;
  final int? timeout;

  const RequestOptions({
    required this.method,
    required this.path,
    this.params,
    this.encryption,
    this.timeout,
  });
}

/// Execute an HTTP request to the t1yOS API with full auth and encryption handling.
Future<ApiResponse<T>> executeRequest<T>(
  T1YInternalConfig client,
  RequestOptions options,
) async {
  final method = options.method;
  final path = options.path;
  final params = options.params;
  final isSafeMode = options.encryption ?? client.isSafeMode;
  final timeoutSeconds = options.timeout ?? requestTimeoutSeconds;

  // Normalize base URL
  final baseUrl = normalizeBaseUrl(client.baseUrl);

  // Build full URL
  final fullUrl = '$baseUrl$path';

  // Convert Date types in params
  final convertedParams = convertDateTypes(params);

  // Handle request body
  String rawBodyString = '';
  dynamic bodyForRequest;

  if (method != HttpMethod.GET) {
    if (isSafeMode && convertedParams != null) {
      // Safe mode: encrypt the JSON body
      final jsonBody = jsonEncode(convertedParams);
      rawBodyString = encryptAESGCM(jsonBody, Uint8List.fromList(utf8.encode(client.secretKey)));
      bodyForRequest = rawBodyString;
    } else if (convertedParams != null) {
      rawBodyString = jsonEncode(convertedParams);
      bodyForRequest = rawBodyString;
    }
  }

  // For GET requests, append params as query string
  String requestUrl = fullUrl;
  if (method == HttpMethod.GET &&
      convertedParams != null &&
      convertedParams is Map &&
      convertedParams.isNotEmpty) {
    requestUrl = appendQueryParams(
      fullUrl,
      Map<String, dynamic>.from(convertedParams),
    );
  }

  // Compute timestamp with offset
  final timestamp = int.parse(getSafeTimestamp(client.offset));

  // Get the path + query for signing
  final uri = Uri.parse(requestUrl);
  final pathAndQuery = uri.path + (uri.hasQuery ? '?${uri.query}' : '');

  // Create the HMAC-SHA256 signature
  final sign = createSignature(SignatureInput(
    method: method.name,
    pathAndQuery: pathAndQuery,
    body: rawBodyString,
    appId: client.appId,
    timestamp: timestamp,
    secretKey: client.secretKey,
  ));

  // Build headers
  final headers = <String, String>{
    'X-T1Y-Application-ID': client.appId.toString(),
    'X-T1Y-API-Key': client.apiKey,
    'X-T1Y-Safe-Timestamp': timestamp.toString(),
    'X-T1Y-Safe-Sign': sign,
    'Content-Type': 'application/json',
  };

  try {
    late http.Response response;

    switch (method) {
      case HttpMethod.GET:
        response = await http
            .get(Uri.parse(requestUrl), headers: headers)
            .timeout(Duration(seconds: timeoutSeconds));
        break;
      case HttpMethod.POST:
        response = await http
            .post(
              Uri.parse(requestUrl),
              headers: headers,
              body: bodyForRequest,
            )
            .timeout(Duration(seconds: timeoutSeconds));
        break;
      case HttpMethod.PUT:
        response = await http
            .put(
              Uri.parse(requestUrl),
              headers: headers,
              body: bodyForRequest,
            )
            .timeout(Duration(seconds: timeoutSeconds));
        break;
      case HttpMethod.DELETE:
        final deleteRequest = http.Request('DELETE', Uri.parse(requestUrl));
        deleteRequest.headers.addAll(headers);
        if (bodyForRequest != null) {
          deleteRequest.body = bodyForRequest;
        }
        final streamed = await deleteRequest
            .send()
            .timeout(Duration(seconds: timeoutSeconds));
        response = await http.Response.fromStream(streamed);
        break;
    }

    return await handleResponse<T>(
      response,
      isSafeMode,
      client.secretKey,
      client.timeFormat,
    );
  } catch (error) {
    return handleFetchError(error);
  }
}
