// Default values and constraints for the t1yOS SDK.

/// Default base URL for the t1yOS platform
const String defaultBaseUrl = 'https://myapp.t1y.net';

/// Minimum valid application ID
const int minAppId = 1001;

/// Required length for API Key
const int apiKeyLength = 32;

/// Required length for Secret Key
const int secretKeyLength = 32;

/// Default application version
const int defaultVersion = 0;

/// Default time format for createdAt/updatedAt fields
const String defaultTimeFormat = 'YYYY-MM-DD HH:mm:ss';

/// Default time offset in seconds
const int defaultOffset = 0;

/// Default safe mode setting
const bool defaultSafeMode = false;

/// Request timeout in seconds (5 minutes)
const int requestTimeoutSeconds = 300;

/// Maximum page size for find queries
const int maxPageSize = 100;

/// Default page size
const int defaultPageSize = 10;

/// ObjectID hex string length
const int objectIdLength = 24;

/// ObjectID hex pattern
final RegExp objectIdPattern = RegExp(r'^[0-9a-fA-F]{24}$');

/// API version prefix
const String apiVersion = 'v5';
