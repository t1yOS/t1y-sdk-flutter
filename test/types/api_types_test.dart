import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('ApiResponse', () {
    test('has correct properties', () {
      final response = ApiResponse<int>(
        code: 200,
        message: 'ok',
        data: 42,
      );

      expect(response.code, 200);
      expect(response.message, 'ok');
      expect(response.data, 42);
    });

    test('fromJson parses correctly', () {
      final response = ApiResponse.fromJson(
        {'code': 201, 'message': 'created', 'data': 100},
        (d) => d as int,
      );

      expect(response.code, 201);
      expect(response.message, 'created');
      expect(response.data, 100);
    });

    test('fromJson with string data', () {
      final response = ApiResponse.fromJson(
        {'code': 200, 'message': 'ok', 'data': 'hello'},
        (d) => d as String,
      );

      expect(response.data, 'hello');
    });

    test('fromJson with Map data', () {
      final response = ApiResponse.fromJson(
        {
          'code': 200,
          'message': 'ok',
          'data': {'key': 'value'},
        },
        (d) => d as Map<String, dynamic>,
      );

      expect(response.data, {'key': 'value'});
    });
  });

  group('InsertResult', () {
    test('fromJson parses objectId', () {
      final result = InsertResult.fromJson({'objectId': '507f1f77bcf86cd799439011'});
      expect(result.objectId, '507f1f77bcf86cd799439011');
    });

    test('fromJson handles missing field', () {
      final result = InsertResult.fromJson({});
      expect(result.objectId, '');
    });
  });

  group('InsertManyResult', () {
    test('fromJson parses correctly', () {
      final result = InsertManyResult.fromJson({
        'objectIds': ['id1', 'id2', 'id3'],
        'insertedCount': 3,
      });
      expect(result.objectIds, ['id1', 'id2', 'id3']);
      expect(result.insertedCount, 3);
    });

    test('fromJson handles empty', () {
      final result = InsertManyResult.fromJson({});
      expect(result.objectIds, []);
      expect(result.insertedCount, 0);
    });
  });

  group('DeleteResult', () {
    test('fromJson parses deletedCount', () {
      final result = DeleteResult.fromJson({'deletedCount': 5});
      expect(result.deletedCount, 5);
    });

    test('fromJson handles missing', () {
      expect(DeleteResult.fromJson({}).deletedCount, 0);
    });
  });

  group('DeleteManyResult', () {
    test('fromJson parses deletedCount', () {
      final result = DeleteManyResult.fromJson({'deletedCount': 10});
      expect(result.deletedCount, 10);
    });
  });

  group('UpdateResult', () {
    test('fromJson parses modifiedCount', () {
      final result = UpdateResult.fromJson({'modifiedCount': 1});
      expect(result.modifiedCount, 1);
    });
  });

  group('UpdateManyResult', () {
    test('fromJson parses modifiedCount', () {
      final result = UpdateManyResult.fromJson({'modifiedCount': 7});
      expect(result.modifiedCount, 7);
    });
  });

  group('FindResult', () {
    test('fromJson parses result map', () {
      final result = FindResult.fromJson({
        'result': {
          '_id': '507f1f77bcf86cd799439011',
          'name': 'Alice',
          'age': 30,
        },
      });
      expect(result.result, isNotNull);
      expect(result.result!['name'], 'Alice');
    });

    test('fromJson handles missing result', () {
      final result = FindResult.fromJson({});
      expect(result.result, isNull);
    });
  });

  group('Pagination', () {
    test('fromJson parses correctly', () {
      final pagination = Pagination.fromJson({'totalItems': 100, 'totalPages': 10});
      expect(pagination.totalItems, 100);
      expect(pagination.totalPages, 10);
    });
  });

  group('PaginationResult', () {
    test('fromJson parses full structure', () {
      final result = PaginationResult.fromJson({
        'results': [
          {'name': 'Alice'},
          {'name': 'Bob'},
        ],
        'page': 1,
        'size': 10,
        'pagination': {'totalItems': 2, 'totalPages': 1},
      });

      expect(result.results.length, 2);
      expect(result.results[0]['name'], 'Alice');
      expect(result.page, 1);
      expect(result.size, 10);
      expect(result.pagination.totalItems, 2);
    });

    test('fromJson handles empty', () {
      final result = PaginationResult.fromJson({});
      expect(result.results, []);
      expect(result.page, 1);
      expect(result.size, 10);
      expect(result.pagination.totalItems, 0);
    });
  });

  group('AggregateResult', () {
    test('fromJson parses results', () {
      final result = AggregateResult.fromJson({
        'results': [
          {'_id': null, 'total': 500},
        ],
      });
      expect(result.results.length, 1);
      expect(result.results[0]['total'], 500);
    });

    test('fromJson handles empty', () {
      final result = AggregateResult.fromJson({});
      expect(result.results, []);
    });
  });

  group('InitResult', () {
    test('fromJson parses correctly', () {
      final result = InitResult.fromJson({'unix': 1705312200, 'is_safe_mode': true});
      expect(result.unix, 1705312200);
      expect(result.isSafeMode, true);
    });

    test('fromJson handles defaults', () {
      final result = InitResult.fromJson({});
      expect(result.unix, 0);
      expect(result.isSafeMode, false);
    });
  });

  group('AESGCMPayload', () {
    test('creates and serializes correctly', () {
      final payload = AESGCMPayload(n: 'nonce', j: 'cipher', t: 'tag');
      final json = payload.toJson();
      expect(json['n'], 'nonce');
      expect(json['j'], 'cipher');
      expect(json['t'], 'tag');
    });

    test('fromJson parses correctly', () {
      final payload = AESGCMPayload.fromJson({'n': 'n1', 'j': 'j1', 't': 't1'});
      expect(payload.n, 'n1');
      expect(payload.j, 'j1');
      expect(payload.t, 't1');
    });

    test('fromJson handles empty', () {
      final payload = AESGCMPayload.fromJson({});
      expect(payload.n, '');
      expect(payload.j, '');
      expect(payload.t, '');
    });
  });

  group('SignatureInput', () {
    test('stores all fields', () {
      final input = SignatureInput(
        method: 'POST',
        pathAndQuery: '/test',
        body: '{}',
        appId: 1001,
        timestamp: 1000,
        secretKey: 'k' * 32,
      );

      expect(input.method, 'POST');
      expect(input.pathAndQuery, '/test');
      expect(input.body, '{}');
      expect(input.appId, 1001);
      expect(input.timestamp, 1000);
      expect(input.secretKey, 'k' * 32);
    });
  });
}
