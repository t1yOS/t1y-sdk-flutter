import '../utils/constants.dart';
import '../utils/errors.dart';
import '../types/client_types.dart';

/// Validate that the application ID is a valid integer >= minAppId.
void validateAppId(int appId) {
  if (appId < minAppId) {
    throw ValidationError('appId must be >= $minAppId');
  }
}

/// Validate that the API Key is exactly the required length.
void validateApiKey(String apiKey) {
  if (apiKey.length != apiKeyLength) {
    throw ValidationError(
      'apiKey must be exactly $apiKeyLength characters (got ${apiKey.length})',
    );
  }
}

/// Validate that the Secret Key is exactly the required length.
void validateSecretKey(String secretKey) {
  if (secretKey.length != secretKeyLength) {
    throw ValidationError(
      'secretKey must be exactly $secretKeyLength characters (got ${secretKey.length})',
    );
  }
}

/// Validate the base URL format.
void validateBaseUrl(String baseUrl) {
  if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
    throw ValidationError('baseUrl must start with "http://" or "https://"');
  }
}

/// Validate all configuration parameters at once.
void validateInitConfig(T1YClientConfig config) {
  if (config.baseUrl != null) {
    validateBaseUrl(config.baseUrl!);
  }
  validateAppId(config.appId);
  validateApiKey(config.apiKey);
  validateSecretKey(config.secretKey);

  if (config.version != null &&
      (config.version! < 0)) {
    throw ValidationError('version must be a non-negative integer');
  }
}

/// Validate an ObjectID hex string.
/// Returns true if valid, throws otherwise.
bool assertObjectID(String idStr, [String name = 'ObjectID']) {
  if (!objectIdPattern.hasMatch(idStr)) {
    throw ValidationError('Invalid $name string: "$idStr"');
  }
  return true;
}
