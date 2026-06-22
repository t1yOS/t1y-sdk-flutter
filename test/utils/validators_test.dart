import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('validateAppId', () {
    test('throws for appId < minAppId (1001)', () {
      expect(
        () => validateAppId(500),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateAppId(0),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateAppId(-1),
        throwsA(isA<ValidationError>()),
      );
    });

    test('passes for valid appId', () {
      expect(() => validateAppId(1001), returnsNormally);
      expect(() => validateAppId(9999), returnsNormally);
    });
  });

  group('validateApiKey', () {
    test('throws for wrong length', () {
      expect(
        () => validateApiKey(''),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateApiKey('short'),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateApiKey('x' * 31),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateApiKey('x' * 33),
        throwsA(isA<ValidationError>()),
      );
    });

    test('passes for exactly 32 characters', () {
      expect(() => validateApiKey('a' * 32), returnsNormally);
    });
  });

  group('validateSecretKey', () {
    test('throws for wrong length', () {
      expect(
        () => validateSecretKey('short'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('passes for exactly 32 characters', () {
      expect(() => validateSecretKey('s' * 32), returnsNormally);
    });
  });

  group('validateBaseUrl', () {
    test('throws for non-http schemes', () {
      expect(
        () => validateBaseUrl('ftp://example.com'),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateBaseUrl('ws://example.com'),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => validateBaseUrl('example.com'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('passes for http and https', () {
      expect(() => validateBaseUrl('http://localhost'), returnsNormally);
      expect(() => validateBaseUrl('https://myapp.t1y.net'), returnsNormally);
    });
  });

  group('validateInitConfig', () {
    test('throws when any required field is invalid', () {
      // Bad appId
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 500,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
        )),
        throwsA(isA<ValidationError>()),
      );

      // Bad apiKey
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 1001,
          apiKey: 'short',
          secretKey: 'b' * 32,
        )),
        throwsA(isA<ValidationError>()),
      );

      // Bad secretKey
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'bad',
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws for invalid custom baseUrl', () {
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
          baseUrl: 'not-a-url',
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws for negative version', () {
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
          version: -1,
        )),
        throwsA(isA<ValidationError>()),
      );
    });

    test('passes for valid config with all defaults', () {
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 1001,
          apiKey: 'a' * 32,
          secretKey: 'b' * 32,
        )),
        returnsNormally,
      );
    });

    test('passes for valid config with all custom fields', () {
      expect(
        () => validateInitConfig(T1YClientConfig(
          appId: 2000,
          apiKey: 'k' * 32,
          secretKey: 's' * 32,
          baseUrl: 'https://custom.example.com',
          version: 5,
          isSafeMode: true,
          timeFormat: 'YYYY/MM/DD',
          offset: 10,
        )),
        returnsNormally,
      );
    });
  });

  group('assertObjectID', () {
    test('returns true for valid 24-char hex', () {
      expect(assertObjectID('507f1f77bcf86cd799439011'), true);
      expect(assertObjectID('abcdef1234567890abcdef12'), true);
      expect(assertObjectID('ABCDEF1234567890ABCDEF12'), true); // uppercase OK
    });

    test('throws for invalid string', () {
      expect(
        () => assertObjectID('too-short'),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => assertObjectID(''),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws for 24-char non-hex string', () {
      expect(
        () => assertObjectID('zzzzzzzzzzzzzzzzzzzzzzzz'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('throws for wrong length', () {
      expect(
        () => assertObjectID('a' * 23),
        throwsA(isA<ValidationError>()),
      );
      expect(
        () => assertObjectID('a' * 25),
        throwsA(isA<ValidationError>()),
      );
    });

    test('custom name appears in error', () {
      try {
        assertObjectID('bad', 'CustomName');
      } catch (e) {
        expect(e.toString(), contains('CustomName'));
      }
    });
  });
}
