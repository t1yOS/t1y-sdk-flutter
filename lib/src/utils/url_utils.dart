import 'dart:convert';

/// Strip trailing slashes from a base URL.
String normalizeBaseUrl(String baseUrl) {
  return baseUrl.replaceAll(RegExp(r'\/+$'), '');
}

/// Append query parameters from a params Map to a URI query string.
/// Skips null values. String values are added directly; others are JSON-encoded.
String appendQueryParams(String basePath, Map<String, dynamic> params) {
  final uri = Uri.parse(basePath);
  final queryParams = Map<String, String>.from(uri.queryParameters);

  for (final key in params.keys) {
    final value = params[key];
    if (value == null) continue;
    queryParams[key] = value is String ? value : jsonEncode(value);
  }

  return uri.replace(queryParameters: queryParams).toString();
}
