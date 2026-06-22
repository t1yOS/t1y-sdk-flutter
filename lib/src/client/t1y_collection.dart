import '../types/client_types.dart';
import '../types/api_types.dart';
import '../utils/constants.dart';
import '../utils/convert.dart';
import '../utils/validators.dart';
import 't1y_client.dart';

/// Database collection class providing chainable CRUD and schema operations.
///
/// Created via `client.db.collection('name')` — never instantiated directly.
class T1YCollection {
  final T1YClient _client;
  final String _name;

  /// @internal — Use `client.db.collection(name)` instead.
  T1YCollection(this._client, this._name);

  // ==================== Single Document Operations ====================

  /// Insert one document into the collection.
  ///
  /// Returns response with the inserted document's ObjectID.
  Future<ApiResponse<InsertResult>> insertOne(Map<String, dynamic> data) async {
    if (!isNonEmptyObject(data)) {
      throw ArgumentError('insertOne data must be a non-empty plain object');
    }
    return await _client.request<InsertResult>(
      HttpMethod.POST,
      '/v5/classes/$_name',
      data,
    );
  }

  /// Delete one document by ObjectID.
  Future<ApiResponse<DeleteResult>> deleteById(String objectId) async {
    assertObjectID(objectId);
    return await _client.request<DeleteResult>(
      HttpMethod.DELETE,
      '/v5/classes/$_name/$objectId',
    );
  }

  /// Update one document by ObjectID.
  Future<ApiResponse<UpdateResult>> updateById(
    String objectId,
    Map<String, dynamic> data,
  ) async {
    assertObjectID(objectId);
    if (!isNonEmptyObject(data)) {
      throw ArgumentError('update data must be a non-empty plain object');
    }
    return await _client.request<UpdateResult>(
      HttpMethod.PUT,
      '/v5/classes/$_name/$objectId',
      data,
    );
  }

  /// Find one document by ObjectID.
  Future<ApiResponse<FindResult>> findById(String objectId) async {
    assertObjectID(objectId);
    return await _client.request<FindResult>(
      HttpMethod.GET,
      '/v5/classes/$_name/$objectId',
    );
  }

  // ==================== Filter-based Single Operations ====================

  /// Delete one document matching the filter.
  Future<ApiResponse<DeleteResult>> deleteOne(
    Map<String, dynamic> filter,
  ) async {
    if (!isNonEmptyObject(filter)) {
      throw ArgumentError('deleteOne filter must be a non-empty plain object');
    }
    return await _client.request<DeleteResult>(
      HttpMethod.DELETE,
      '/v5/classes/$_name/one',
      filter,
    );
  }

  /// Update one document matching the filter.
  Future<ApiResponse<UpdateResult>> updateOne(
    Map<String, dynamic> filter,
    Map<String, dynamic> body,
  ) async {
    if (!isNonEmptyObject(filter)) {
      throw ArgumentError('updateOne filter must be a non-empty plain object');
    }
    if (!isNonEmptyObject(body)) {
      throw ArgumentError('updateOne body must be a non-empty plain object');
    }
    return await _client.request<UpdateResult>(
      HttpMethod.PUT,
      '/v5/classes/$_name/one',
      {'filter': filter, 'body': body},
    );
  }

  /// Find one document matching the filter.
  Future<ApiResponse<FindResult>> findOne(Map<String, dynamic> filter) async {
    if (!isNonEmptyObject(filter)) {
      throw ArgumentError('findOne filter must be a non-empty plain object');
    }
    return await _client.request<FindResult>(
      HttpMethod.POST,
      '/v5/classes/$_name/one',
      filter,
    );
  }

  // ==================== Bulk Operations ====================

  /// Insert multiple documents into the collection.
  Future<ApiResponse<InsertManyResult>> insertMany(
    List<Map<String, dynamic>> dataList,
  ) async {
    if (!isNonEmptyListWithNonEmptyObjects(dataList)) {
      throw ArgumentError(
        'insertMany dataList must be a non-empty list of non-empty plain objects',
      );
    }
    return await _client.request<InsertManyResult>(
      HttpMethod.POST,
      '/v5/classes/$_name/many',
      dataList,
    );
  }

  /// Delete multiple documents matching the filter.
  Future<ApiResponse<DeleteManyResult>> deleteMany(
    Map<String, dynamic> filter,
  ) async {
    if (!isPlainObject(filter)) {
      throw ArgumentError('deleteMany filter must be a plain object');
    }
    return await _client.request<DeleteManyResult>(
      HttpMethod.DELETE,
      '/v5/classes/$_name/many',
      filter,
    );
  }

  /// Update multiple documents matching the filter.
  Future<ApiResponse<UpdateManyResult>> updateMany(
    Map<String, dynamic> filter,
    Map<String, dynamic> body,
  ) async {
    if (!isPlainObject(filter)) {
      throw ArgumentError('updateMany filter must be a plain object');
    }
    if (!isNonEmptyObject(body)) {
      throw ArgumentError('updateMany body must be a non-empty plain object');
    }
    return await _client.request<UpdateManyResult>(
      HttpMethod.PUT,
      '/v5/classes/$_name/many',
      {'filter': filter, 'body': body},
    );
  }

  // ==================== Advanced Queries ====================

  /// Paginated find query with sorting and filtering.
  Future<ApiResponse<PaginationResult>> find({
    int page = 1,
    int size = 10,
    Map<String, int> sort = const {'createdAt': -1},
    Map<String, dynamic> filter = const {},
  }) async {
    if (page < 1) {
      throw ArgumentError('find page must be a positive integer');
    }
    if (size < 1) {
      throw ArgumentError('find size must be a positive integer');
    }
    if (size > maxPageSize) {
      size = maxPageSize;
    }
    if (!isNonEmptyObject(sort)) {
      throw ArgumentError('find sort must be a non-empty plain object');
    }
    if (!isPlainObject(filter)) {
      throw ArgumentError('find filter must be a plain object');
    }

    return await _client.request<PaginationResult>(
      HttpMethod.POST,
      '/v5/classes/$_name/find',
      {'page': page, 'size': size, 'sort': sort, 'filter': filter},
    );
  }

  /// Execute a MongoDB aggregation pipeline.
  Future<ApiResponse<AggregateResult>> aggregate(
    List<Map<String, dynamic>> pipeline,
  ) async {
    if (pipeline.isEmpty) {
      throw ArgumentError('aggregate pipeline must not be empty');
    }
    return await _client.request<AggregateResult>(
      HttpMethod.POST,
      '/v5/classes/$_name/aggregate',
      pipeline,
    );
  }

  /// Count documents matching a filter.
  Future<ApiResponse<Map<String, dynamic>>> count({
    Map<String, dynamic> filter = const {},
  }) async {
    if (!isPlainObject(filter)) {
      throw ArgumentError('count filter must be a plain object');
    }
    return await _client.request<Map<String, dynamic>>(
      HttpMethod.POST,
      '/v5/classes/$_name/count',
      filter,
    );
  }

  /// Get distinct values for a field, optionally filtered.
  Future<ApiResponse<Map<String, dynamic>>> distinct(
    String fieldName, {
    Map<String, dynamic> filter = const {},
  }) async {
    if (fieldName.isEmpty) {
      throw ArgumentError('distinct fieldName must be a non-empty string');
    }
    if (!isPlainObject(filter)) {
      throw ArgumentError('distinct filter must be a plain object');
    }
    return await _client.request<Map<String, dynamic>>(
      HttpMethod.POST,
      '/v5/classes/$_name/distinct/${Uri.encodeComponent(fieldName)}',
      filter,
    );
  }

  // ==================== Schema Management ====================

  /// Create this collection (table) in the application's database.
  Future<ApiResponse> create() async {
    return await _client.request(
      HttpMethod.POST,
      '/v5/schemas/${Uri.encodeComponent(_name)}',
    );
  }

  /// Clear all documents from this collection without dropping it.
  Future<ApiResponse<Map<String, dynamic>>> clear() async {
    return await _client.request<Map<String, dynamic>>(
      HttpMethod.PUT,
      '/v5/schemas/${Uri.encodeComponent(_name)}',
    );
  }

  /// Drop (delete) this collection entirely.
  Future<ApiResponse> drop() async {
    return await _client.request(
      HttpMethod.DELETE,
      '/v5/schemas/${Uri.encodeComponent(_name)}',
    );
  }
}
