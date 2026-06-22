import 'package:flutter_test/flutter_test.dart';

import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  // ==================== Configuration Tests ====================
  group('T1YClientConfig', () {
    test('should create a valid config with required fields', () {
      final config = T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      );

      expect(config.appId, 1001);
      expect(config.apiKey.length, 32);
      expect(config.secretKey.length, 32);
    });

    test('should allow optional fields', () {
      final config = T1YClientConfig(
        appId: 2000,
        apiKey: 'k' * 32,
        secretKey: 's' * 32,
        baseUrl: 'https://custom.t1y.net',
        version: 5,
        isSafeMode: true,
        timeFormat: 'YYYY/MM/DD',
        offset: 10,
      );

      expect(config.baseUrl, 'https://custom.t1y.net');
      expect(config.version, 5);
      expect(config.isSafeMode, true);
      expect(config.timeFormat, 'YYYY/MM/DD');
      expect(config.offset, 10);
    });
  });

  // ==================== Validation Tests ====================
  group('Validators', () {
    test('validateAppId should throw on invalid appId', () {
      expect(() => validateAppId(500), throwsA(isA<ValidationError>()));
      expect(() => validateAppId(1001), returnsNormally);
    });

    test('validateApiKey should throw on invalid length', () {
      expect(
        () => validateApiKey('short'),
        throwsA(isA<ValidationError>()),
      );
      expect(() => validateApiKey('a' * 32), returnsNormally);
    });

    test('validateSecretKey should throw on invalid length', () {
      expect(
        () => validateSecretKey('short'),
        throwsA(isA<ValidationError>()),
      );
      expect(() => validateSecretKey('s' * 32), returnsNormally);
    });

    test('validateBaseUrl should throw on invalid URL', () {
      expect(
        () => validateBaseUrl('ftp://invalid'),
        throwsA(isA<ValidationError>()),
      );
      expect(() => validateBaseUrl('https://valid.com'), returnsNormally);
      expect(() => validateBaseUrl('http://valid.com'), returnsNormally);
    });

    test('validateInitConfig should validate all fields', () {
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 500,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
        )),
        throwsA(isA<ValidationError>()),
      );

      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
        )),
        returnsNormally,
      );
    });

    test('assertObjectID should validate hex strings', () {
      expect(
        () => assertObjectID('invalid'),
        throwsA(isA<ValidationError>()),
      );
      final validId = '507f1f77bcf86cd799439011';
      expect(assertObjectID(validId), true);
    });
  });

  // ==================== Crypto Tests ====================
  group('SHA-256', () {
    test('sha256Hex should produce 64-char hex string', () {
      final hash = sha256Hex('hello');
      expect(hash.length, 64);
      expect(hash, isNot(contains(' ')));
    });

    test('sha256Hex should be deterministic', () {
      final hash1 = sha256Hex('test');
      final hash2 = sha256Hex('test');
      expect(hash1, hash2);
    });

    test('sha256Hex should produce different hashes for different inputs', () {
      final hash1 = sha256Hex('hello');
      final hash2 = sha256Hex('world');
      expect(hash1, isNot(hash2));
    });
  });

  group('HMAC-SHA256', () {
    test('hmacSHA256Hex should produce 64-char hex string', () {
      final hmac = hmacSHA256Hex('secret', 'message');
      expect(hmac.length, 64);
    });

    test('verifyHmacSHA256 should verify correct signature', () {
      final secret = 'my-secret-key';
      final message = 'test-message';
      final signature = hmacSHA256Hex(secret, message);
      expect(verifyHmacSHA256(secret, message, signature), true);
    });

    test('verifyHmacSHA256 should reject incorrect signature', () {
      final secret = 'my-secret-key';
      final message = 'test-message';
      expect(verifyHmacSHA256(secret, message, 'wrong'), false);
    });
  });

  group('Signature', () {
    test('createSignature should produce 64-char hex string', () {
      final signature = createSignature(SignatureInput(
        method: 'POST',
        pathAndQuery: '/v5/classes/users',
        body: '{"name":"Alice"}',
        appId: 1001,
        timestamp: 1705312200,
        secretKey: 's' * 32,
      ));
      expect(signature.length, 64);
    });
  });

  // ==================== Special Types Tests ====================
  group('Special Types', () {
    test('objectIdMarker should produce valid marker', () {
      final marker = objectIdMarker('507f1f77bcf86cd799439011');
      expect(marker, "ObjectID('507f1f77bcf86cd799439011')");
    });

    test('objectIdMarker should throw on invalid hex', () {
      expect(
        () => objectIdMarker('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('dateMarker should produce valid marker', () {
      final marker = dateMarker('2024-01-15T10:30:00Z');
      expect(marker, "Date('2024-01-15T10:30:00Z')");
    });

    test('dateTimeMarker should produce valid marker', () {
      final marker = dateTimeMarker('2024-06-15T14:30:00Z');
      expect(marker, "DateTime('2024-06-15T14:30:00Z')");
    });

    test('timestampMarker should produce valid marker', () {
      final marker = timestampMarker(1705312200);
      expect(marker, "Timestamp('1705312200')");
    });

    test('booleanMarker should produce valid marker', () {
      expect(booleanMarker(true), 'Boolean(true)');
      expect(booleanMarker(false), 'Boolean(false)');
    });

    test('integerMarker should produce valid marker', () {
      expect(integerMarker(42), 'Integer(42)');
    });

    test('bigintMarker should produce valid marker', () {
      expect(bigintMarker(9007199254740991), 'Bigint(9007199254740991)');
    });

    test('floatMarker should produce valid marker', () {
      expect(floatMarker(4.5), 'Float(4.5)');
    });

    test('doubleMarker should produce valid marker', () {
      expect(doubleMarker(3.141592653589793), 'Double(3.141592653589793)');
    });

    test('arrayMarker should produce valid marker', () {
      final marker = arrayMarker(['a', 'b']);
      expect(marker, 'Array(["a","b"])');
    });

    test('mapMarker should produce valid marker', () {
      final marker = mapMarker({'key': 'val'});
      expect(marker, 'Map({"key":"val"})');
    });

    test('mapArrayMarker should produce valid marker', () {
      final marker = mapArrayMarker([{'a': 1}]);
      expect(marker, 'Map[]([{"a":1}])');
    });

    test('null markers should be correct constants', () {
      expect(nullValue, 'Null');
      expect(noneValue, 'None');
      expect(nilValue, 'Nil');
      expect(emptyValue, '');
      expect(undefinedUpper, 'UNDEFINED');
      expect(undefinedValue, 'Undefined');
    });

    test('timeNow should produce correct markers', () {
      expect(timeNow.now(), 'time.Now()');
      expect(timeNow.nowUnix(), 'time.Now().Unix()');
      expect(timeNow.nowUnixNano(), 'time.Now().UnixNano()');
      expect(timeNow.nowWeekday(), 'time.Now().Weekday()');
      expect(timeNow.nowWeekdayChinese(), 'time.Now().Weekday().Chinese()');
    });
  });

  // ==================== Utility Tests ====================
  group('URL Utilities', () {
    test('normalizeBaseUrl should strip trailing slashes', () {
      expect(normalizeBaseUrl('https://example.com/'), 'https://example.com');
      expect(normalizeBaseUrl('https://example.com//'), 'https://example.com');
      expect(normalizeBaseUrl('https://example.com'), 'https://example.com');
    });

    test('appendQueryParams should add params to URL', () {
      final result = appendQueryParams(
        'https://example.com/api',
        {'key': 'value', 'num': 42},
      );
      expect(result, contains('key=value'));
      expect(result, contains('num=42'));
    });
  });

  group('Object Checks', () {
    test('isNonEmptyObject should detect non-empty Maps', () {
      expect(isNonEmptyObject({'a': 1}), true);
      expect(isNonEmptyObject({}), false);
      expect(isNonEmptyObject('string'), false);
      expect(isNonEmptyObject([]), false);
      expect(isNonEmptyObject(null), false);
    });

    test('isPlainObject should detect Maps', () {
      expect(isPlainObject({'a': 1}), true);
      expect(isPlainObject({}), true);
      expect(isPlainObject([]), false);
      expect(isPlainObject(null), false);
    });

    test('isNonEmptyListWithNonEmptyObjects should validate correctly', () {
      expect(
        isNonEmptyListWithNonEmptyObjects([{'a': 1}]),
        true,
      );
      expect(isNonEmptyListWithNonEmptyObjects([]), false);
      expect(isNonEmptyListWithNonEmptyObjects([{}]), false);
      expect(isNonEmptyListWithNonEmptyObjects('string'), false);
    });
  });

  group('Time Utilities', () {
    test('formatLocalTime should format valid timestamps', () {
      final result = formatLocalTime(
        '2024-01-15T10:30:00.000Z',
        'YYYY-MM-DD HH:mm:ss',
      );
      expect(result, isNotNull);
      // Output depends on local timezone — just check it's different from input
    });
  });

  // ==================== Client Tests ====================
  group('T1YClient', () {
    test('should create a client with valid config', () {
      final client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
      expect(client, isNotNull);
    });

    test('should throw ValidationError with invalid config', () {
      expect(
        () => T1YClient(T1YClientConfig(
          appId: 500,
          apiKey: 'short',
          secretKey: 'short',
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('db.collection should return a T1YCollection', () {
      final client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
      final collection = client.db.collection('users');
      expect(collection, isNotNull);
    });

    test('db.toObjectID should produce ObjectID marker', () {
      final client = T1YClient(T1YClientConfig(
        appId: 1001,
        apiKey: 'a' * 32,
        secretKey: 'b' * 32,
      ));
      final marker = client.db.toObjectID('507f1f77bcf86cd799439011');
      expect(marker, "ObjectID('507f1f77bcf86cd799439011')");
    });
  });

  // ==================== Error Tests ====================
  group('Errors', () {
    test('T1YError should have correct properties', () {
      final error = T1YError(404, 'Not found', {'detail': 'missing'});
      expect(error.code, 404);
      expect(error.message, 'Not found');
      expect(error.data, {'detail': 'missing'});
    });

    test('ValidationError should have correct message', () {
      final error = ValidationError('Invalid appId');
      expect(error.message, 'Invalid appId');
    });
  });

  // ==================== Constants Tests ====================
  group('Constants', () {
    test('should have correct default values', () {
      expect(defaultBaseUrl, 'https://myapp.t1y.net');
      expect(minAppId, 1001);
      expect(apiKeyLength, 32);
      expect(secretKeyLength, 32);
      expect(defaultVersion, 0);
      expect(maxPageSize, 100);
      expect(objectIdLength, 24);
    });
  });
}
