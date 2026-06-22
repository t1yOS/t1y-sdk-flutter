/// Configuration for initializing the t1yOS client.
class T1YClientConfig {
  /// Base URL of the t1yOS platform. Default: 'https://myapp.t1y.net'
  final String? baseUrl;

  /// Application ID. Required, must be an integer >= 1001
  final int appId;

  /// API Key. Required, must be exactly 32 characters
  final String apiKey;

  /// Secret Key. Required, must be exactly 32 characters
  final String secretKey;

  /// Application version. Default: 0
  final int? version;

  /// Whether to enable safe mode (AES-256-GCM encryption). Default: false
  final bool? isSafeMode;

  /// Time format for createdAt/updatedAt fields. Default: 'YYYY-MM-DD HH:mm:ss'
  final String? timeFormat;

  /// Time offset in seconds between client and server. Default: 0
  final int? offset;

  const T1YClientConfig({
    this.baseUrl,
    required this.appId,
    required this.apiKey,
    required this.secretKey,
    this.version,
    this.isSafeMode,
    this.timeFormat,
    this.offset,
  });
}

/// Internal configuration with all optional fields resolved to defaults.
class T1YInternalConfig {
  final String baseUrl;
  final int appId;
  final String apiKey;
  final String secretKey;
  final int version;
  bool isSafeMode;
  final String timeFormat;
  int offset;

  T1YInternalConfig({
    required this.baseUrl,
    required this.appId,
    required this.apiKey,
    required this.secretKey,
    required this.version,
    required this.isSafeMode,
    required this.timeFormat,
    required this.offset,
  });
}

/// HTTP methods supported by the SDK
// ignore: constant_identifier_names
enum HttpMethod { GET, POST, PUT, DELETE }
