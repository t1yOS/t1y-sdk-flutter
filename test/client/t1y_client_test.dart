import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  // ==================== Construction ====================

  group('T1YClient construction', () {
    test('creates client with valid config', () {
      final client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
      expect(client, isNotNull);
    });

    test('throws ValidationError for invalid appId', () {
      expect(
        () => T1YClient(T1YClientConfig(
          appId: 500,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws ValidationError for invalid apiKey', () {
      expect(
        () => T1YClient(T1YClientConfig(
          appId: 1001,
          apiKey: 'short',
          secretKey: 'b' * 32,
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws ValidationError for invalid secretKey', () {
      expect(
        () => T1YClient(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'bad',
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws ValidationError for invalid baseUrl', () {
      expect(
        () => T1YClient(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
          baseUrl: 'not-a-url',
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('accepts all optional params', () {
      final client = T1YClient(T1YClientConfig(
        appId: 2000,
        apiKey: 'k' * 32,
        secretKey: 's' * 32,
        baseUrl: 'https://custom.t1y.net',
        version: 10,
        isSafeMode: true,
        timeFormat: 'YYYY/MM/DD',
        offset: 3600,
      ));
      expect(client, isNotNull);
    });
  });

  // ==================== db ====================

  group('T1YClient.db', () {
    late T1YClient client;

    setUp(() {
      client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
    });

    test('db.collection returns T1YCollection', () {
      final coll = client.db.collection('users');
      expect(coll, isNotNull);
    });

    test('db.collection throws on empty name', () {
      expect(
        () => client.db.collection(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('db.toObjectID produces correct marker', () {
      final marker = client.db.toObjectID('507f1f77bcf86cd799439011');
      expect(marker, "ObjectID('507f1f77bcf86cd799439011')");
    });

    test('db.toObjectID throws on invalid id', () {
      expect(
        () => client.db.toObjectID('invalid'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  // ==================== Utility Methods ====================

  group('T1YClient utility methods', () {
    late T1YClient client;

    setUp(() {
      client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
    });

    test('assertObjectID returns true for valid ID', () {
      expect(
        client.assertObjectID('507f1f77bcf86cd799439011'),
        true,
      );
    });

    test('assertObjectID throws for invalid ID', () {
      expect(
        () => client.assertObjectID('bad'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('isNonEmptyObject works correctly', () {
      expect(client.isNonEmptyObject({'a': 1}), true);
      expect(client.isNonEmptyObject({}), false);
      expect(client.isNonEmptyObject(null), false);
    });

    test('isPlainObject works correctly', () {
      expect(client.isPlainObject({'a': 1}), true);
      expect(client.isPlainObject({}), true);
      expect(client.isPlainObject([]), false);
    });

    test('isNonEmptyListWithNonEmptyObjects works correctly', () {
      expect(
        client.isNonEmptyListWithNonEmptyObjects([{'a': 1}]),
        true,
      );
      expect(client.isNonEmptyListWithNonEmptyObjects([]), false);
      expect(client.isNonEmptyListWithNonEmptyObjects([{}]), false);
    });
  });

  // ==================== Crypto ====================

  group('T1YClient crypto', () {
    late T1YClient client;

    setUp(() {
      client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
    });

    test('hmacSHA256 produces 64-char hex', () {
      final result = client.hmacSHA256('message', 'secret');
      expect(result.length, 64);
    });

    test('verifyHmacSHA256 returns true for correct signature', () {
      final secret = 'test-secret';
      final message = 'test-message';
      final signature = client.hmacSHA256(message, secret);

      expect(client.verifyHmacSHA256(secret, message, signature), true);
    });

    test('verifyHmacSHA256 returns false for wrong signature', () {
      expect(
        client.verifyHmacSHA256('secret', 'message', 'wrong'),
        false,
      );
    });
  });

  // ==================== Validation ====================

  group('T1YClient request validation', () {
    late T1YClient client;

    setUp(() {
      client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
    });

    test('getMeta throws on empty string field', () {
      expect(
        () => client.getMeta(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getMeta accepts null field (no filter)', () {
      // This will make a real HTTP call — just verify it doesn't throw on validation
      expect(
        () => client.getMeta(null),
        returnsNormally, // validation passes, HTTP call will fail in test
      );
    });

    test('callFunc throws on empty name', () {
      expect(
        () => client.callFunc(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('request throws on empty path', () {
      expect(
        () => client.request(HttpMethod.GET, ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
