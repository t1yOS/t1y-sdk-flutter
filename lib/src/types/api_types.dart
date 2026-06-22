/// Standard API response wrapper returned by the t1yOS server.
class ApiResponse<T> {
  final int code;
  final String message;
  final T data;

  const ApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? 'ok',
      data: fromJsonT(json['data']),
    );
  }
}

/// Response from insertOne
class InsertResult {
  final String objectId;
  const InsertResult({required this.objectId});

  factory InsertResult.fromJson(Map<String, dynamic> json) {
    return InsertResult(objectId: json['objectId'] as String? ?? '');
  }
}

/// Response from insertMany
class InsertManyResult {
  final List<String> objectIds;
  final int insertedCount;
  const InsertManyResult({required this.objectIds, required this.insertedCount});

  factory InsertManyResult.fromJson(Map<String, dynamic> json) {
    return InsertManyResult(
      objectIds: (json['objectIds'] as List<dynamic>?)?.cast<String>() ?? [],
      insertedCount: json['insertedCount'] as int? ?? 0,
    );
  }
}

/// Response from deleteOne / deleteById
class DeleteResult {
  final int deletedCount;
  const DeleteResult({required this.deletedCount});

  factory DeleteResult.fromJson(Map<String, dynamic> json) {
    return DeleteResult(deletedCount: json['deletedCount'] as int? ?? 0);
  }
}

/// Response from deleteMany
class DeleteManyResult {
  final int deletedCount;
  const DeleteManyResult({required this.deletedCount});

  factory DeleteManyResult.fromJson(Map<String, dynamic> json) {
    return DeleteManyResult(deletedCount: json['deletedCount'] as int? ?? 0);
  }
}

/// Response from updateOne / updateById
class UpdateResult {
  final int modifiedCount;
  const UpdateResult({required this.modifiedCount});

  factory UpdateResult.fromJson(Map<String, dynamic> json) {
    return UpdateResult(modifiedCount: json['modifiedCount'] as int? ?? 0);
  }
}

/// Response from updateMany
class UpdateManyResult {
  final int modifiedCount;
  const UpdateManyResult({required this.modifiedCount});

  factory UpdateManyResult.fromJson(Map<String, dynamic> json) {
    return UpdateManyResult(modifiedCount: json['modifiedCount'] as int? ?? 0);
  }
}

/// Response from findOne / findById
class FindResult {
  final Map<String, dynamic>? result;
  const FindResult({this.result});

  factory FindResult.fromJson(Map<String, dynamic> json) {
    return FindResult(result: json['result'] as Map<String, dynamic>?);
  }
}

/// Pagination metadata
class Pagination {
  final int totalItems;
  final int totalPages;
  const Pagination({required this.totalItems, required this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}

/// Response from find (paginated query)
class PaginationResult {
  final List<Map<String, dynamic>> results;
  final int page;
  final int size;
  final Pagination pagination;

  const PaginationResult({
    required this.results,
    required this.page,
    required this.size,
    required this.pagination,
  });

  factory PaginationResult.fromJson(Map<String, dynamic> json) {
    return PaginationResult(
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 10,
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Response from aggregate
class AggregateResult {
  final List<Map<String, dynamic>> results;
  const AggregateResult({required this.results});

  factory AggregateResult.fromJson(Map<String, dynamic> json) {
    return AggregateResult(
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

/// Init response from GET /init/:appId
class InitResult {
  final int unix;
  final bool isSafeMode;

  const InitResult({required this.unix, required this.isSafeMode});

  factory InitResult.fromJson(Map<String, dynamic> json) {
    return InitResult(
      unix: json['unix'] as int? ?? 0,
      isSafeMode: json['is_safe_mode'] as bool? ?? false,
    );
  }
}

/// AES-GCM encrypted payload structure
class AESGCMPayload {
  final String n;
  final String j;
  final String t;

  const AESGCMPayload({required this.n, required this.j, required this.t});

  Map<String, dynamic> toJson() => {'n': n, 'j': j, 't': t};

  factory AESGCMPayload.fromJson(Map<String, dynamic> json) {
    return AESGCMPayload(
      n: json['n'] as String? ?? '',
      j: json['j'] as String? ?? '',
      t: json['t'] as String? ?? '',
    );
  }
}

/// Parameters for creating a request signature
class SignatureInput {
  final String method;
  final String pathAndQuery;
  final String body;
  final int appId;
  final int timestamp;
  final String secretKey;

  const SignatureInput({
    required this.method,
    required this.pathAndQuery,
    required this.body,
    required this.appId,
    required this.timestamp,
    required this.secretKey,
  });
}
