import '../types/client_types.dart';
import '../types/api_types.dart';
import '../http/request.dart';
import '../crypto/hmac.dart';
import '../utils/constants.dart';
import '../utils/convert.dart';
import '../utils/validators.dart';
import '../utils/errors.dart';
import '../utils/logger.dart';
import 't1y_collection.dart';

/// Main T1Y client class for the t1yOS Serverless Platform SDK.
///
/// Provides:
/// - Initialization with server time sync
/// - Chainable database operations via `db.collection(name)`
/// - Cloud function invocation
/// - Metadata retrieval
/// - Cryptographic utilities
class T1YClient {
  late T1YInternalConfig _config;

  /// Database accessor providing chainable collection operations.
  late final DbAccessor db;

  /// Create a new T1YClient instance.
  ///
  /// [config] - Client configuration (appId, apiKey, secretKey are required)
  ///
  /// Throws [ValidationError] if required parameters are invalid.
  T1YClient(T1YClientConfig config) {
    // Validate required parameters
    validateInitConfig(config);

    _config = T1YInternalConfig(
      baseUrl: config.baseUrl ?? defaultBaseUrl,
      appId: config.appId,
      apiKey: config.apiKey,
      secretKey: config.secretKey,
      version: config.version ?? defaultVersion,
      isSafeMode: config.isSafeMode ?? defaultSafeMode,
      timeFormat: config.timeFormat ?? defaultTimeFormat,
      offset: config.offset ?? defaultOffset,
    );

    db = DbAccessor._(this);
  }

  /// Initialize the SDK by syncing with the server.
  ///
  /// Calls `GET /init/:appId` to:
  /// 1. Get the server's current UTC Unix timestamp
  /// 2. Get the server's isSafeMode setting
  ///
  /// The time offset is computed as: server.unix - client.unix
  Future<void> init() async {
    try {
      final res = await request<InitResult>(
        HttpMethod.GET,
        '/init/${_config.appId}',
        null,
        false,
      );
      _config.isSafeMode = res.data.isSafeMode;
      final nowUnix = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).floor();
      _config.offset = res.data.unix - nowUnix;
    } catch (err) {
      T1YLogger.warning(
        'Failed to get time offset from server, defaulting to 0',
        err,
      );
      _config.isSafeMode = false;
      _config.offset = 0;
    }
  }

  // ==================== Public API ====================

  /// Get application metadata.
  ///
  /// [field] - Optional field name to retrieve a specific metadata field.
  Future<ApiResponse> getMeta([String? field]) async {
    if (field != null && field.isEmpty) {
      throw ArgumentError('Meta field must be a non-empty string');
    }
    final queryPath = field != null && field.isNotEmpty
        ? '?field=${Uri.encodeComponent(field)}'
        : '';
    return await request(HttpMethod.GET, '/v5/meta$queryPath');
  }

  /// Check if there's a newer version of the application available.
  ///
  /// Returns `true` if the server version is greater than the client version.
  Future<bool> checkUpdate() async {
    try {
      final res = await request<Map<String, dynamic>>(
        HttpMethod.GET,
        '/v5/meta?field=version',
      );
      final result = res.data['result'] as int? ?? 0;
      return result > _config.version;
    } catch (_) {
      return false;
    }
  }

  /// Call a cloud function (`.jsc` file).
  ///
  /// If [name] doesn't end with `.jsc`, it's auto-appended.
  /// If [name] ends with `/`, `index.jsc` is appended.
  /// If [name] ends with `.js`, it's replaced with `.jsc`.
  Future<ApiResponse> callFunc(
    String name, [
    dynamic params,
    bool? enableSafeMode,
  ]) async {
    if (name.isEmpty) {
      throw ArgumentError('Function name must be a non-empty string');
    }
    return await request(
      HttpMethod.POST,
      '/${_config.appId}/${_ensureJscExtension(name)}',
      params,
      enableSafeMode,
    );
  }

  /// Core HTTP request method with full authentication and encryption.
  ///
  /// Throws [T1YError] on API errors or network failures.
  Future<ApiResponse<T>> request<T>(
    HttpMethod method,
    String path, [
    dynamic params,
    bool? encryption,
  ]) async {
    if (path.isEmpty) {
      throw ArgumentError('request path must be a non-empty string');
    }

    return await executeRequest<T>(
      _config,
      RequestOptions(
        method: method,
        path: path,
        params: params,
        encryption: encryption ?? _config.isSafeMode,
      ),
    );
  }

  // ==================== Utilities ====================

  /// Validate an ObjectID hex string.
  bool assertObjectID(String idStr, [String name = 'ObjectID']) {
    return validators_assertObjectID(idStr, name);
  }

  /// Check if a value is a non-null, non-list Map with at least one key.
  bool isNonEmptyObject(dynamic value) => convert_isNonEmptyObject(value);

  /// Check if a value is a plain Map.
  bool isPlainObject(dynamic value) => convert_isPlainObject(value);

  /// Check if a value is a non-empty list of non-empty Maps.
  bool isNonEmptyListWithNonEmptyObjects(dynamic value) =>
      convert_isNonEmptyListWithNonEmptyObjects(value);

  // ==================== Crypto ====================

  /// Compute HMAC-SHA256 hash and return hex digest.
  String hmacSHA256(String message, String secret) =>
      hmacSHA256Hex(secret, message);

  /// Verify an HMAC-SHA256 signature.
  bool verifyHmacSHA256(String secret, String message, String signature) =>
      _verifyHmacSHA256(secret, message, signature);

  // ==================== Private Helpers ====================

  /// Ensure a function name has the .jsc extension
  String _ensureJscExtension(String input) {
    var path = input.startsWith('/') ? input.substring(1) : input;

    // Separate hash fragment
    final hashIndex = path.indexOf('#');
    final hash = hashIndex != -1 ? path.substring(hashIndex) : '';
    final withoutHash = hashIndex != -1 ? path.substring(0, hashIndex) : path;

    // Separate query string
    final qIndex = withoutHash.indexOf('?');
    final query = qIndex != -1 ? withoutHash.substring(qIndex) : '';
    var mainPath = qIndex != -1 ? withoutHash.substring(0, qIndex) : withoutHash;

    // Apply extension rules
    if (mainPath.endsWith('/')) {
      mainPath = '${mainPath}index.jsc';
    } else if (mainPath.endsWith('.jsc')) {
      // Already has .jsc — no change
    } else if (mainPath.endsWith('.js')) {
      mainPath = mainPath.replaceAll(RegExp(r'\.js$'), '.jsc');
    } else {
      mainPath = '$mainPath.jsc';
    }

    return '$mainPath$query$hash';
  }
}

/// Database accessor class providing chainable collection operations.
class DbAccessor {
  final T1YClient _client;

  DbAccessor._(this._client);

  /// Get a collection instance for chainable operations.
  T1YCollection collection(String name) {
    if (name.isEmpty) {
      throw ArgumentError('Collection name must be a non-empty string');
    }
    return T1YCollection(_client, name);
  }

  /// Create ObjectID marker string.
  String toObjectID(String id) {
    validators_assertObjectID(id);
    return "ObjectID('$id')";
  }

  /// Get all collections in the application's database.
  Future<ApiResponse<Map<String, dynamic>>> getCollections() async {
    return await _client.request<Map<String, dynamic>>(
      HttpMethod.GET,
      '/v5/schemas',
    );
  }
}

// Local aliases to avoid global name conflicts with class methods
// ignore: non_constant_identifier_names
bool validators_assertObjectID(String idStr, [String name = 'ObjectID']) =>
    assertObjectID(idStr, name);

// ignore: non_constant_identifier_names
bool convert_isNonEmptyObject(dynamic value) => isNonEmptyObject(value);
// ignore: non_constant_identifier_names
bool convert_isPlainObject(dynamic value) => isPlainObject(value);
// ignore: non_constant_identifier_names
bool convert_isNonEmptyListWithNonEmptyObjects(dynamic value) =>
    isNonEmptyListWithNonEmptyObjects(value);

// ignore: non_constant_identifier_names
bool _verifyHmacSHA256(String secret, String message, String signature) =>
    verifyHmacSHA256(secret, message, signature);
