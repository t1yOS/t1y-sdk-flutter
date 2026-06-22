import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';
import 'package:t1y_sdk_flutter/src/http/response.dart';

void main() {
  // ==================== handleResponse ====================

  group('handleResponse — Success cases', () {
    test('parses standard API response with code/message/data', () async {
      final response = http.Response(
        '{"code":200,"message":"ok","data":{"name":"Alice"}}',
        200,
        headers: {'content-type': 'application/json'},
      );

      final result = await handleResponse<Map<String, dynamic>>(
        response,
        false, // not safe mode
        '',
        defaultTimeFormat,
      );

      expect(result.code, 200);
      expect(result.message, 'ok');
      expect(result.data, contains('name'));
    });

    test('handles non-JSON content type as string', () async {
      final response = http.Response('plain text response', 200, headers: {
        'content-type': 'text/plain',
      });

      final result = await handleResponse<String>(
        response,
        false,
        '',
        defaultTimeFormat,
      );

      expect(result.data, 'plain text response');
    });

    test('handles missing content-type header', () async {
      final response = http.Response('just text', 200);

      final result = await handleResponse<String>(
        response,
        false,
        '',
        defaultTimeFormat,
      );

      expect(result.data, 'just text');
    });

    test('wraps non-standard success response', () async {
      final response = http.Response(
        '{"result":"ok"}',
        200,
        headers: {'content-type': 'application/json'},
      );

      final result = await handleResponse<Map<String, dynamic>>(
        response,
        false,
        '',
        defaultTimeFormat,
      );

      expect(result.code, 0);
      expect(result.message, 'ok');
    });
  });

  group('handleResponse — Error cases', () {
    test('throws T1YError for 4xx with standard API response', () async {
      final response = http.Response(
        '{"code":404,"message":"Not found","data":null}',
        404,
        headers: {'content-type': 'application/json'},
      );

      expect(
        () => handleResponse(
          response,
          false,
          '',
          defaultTimeFormat,
        ),
        throwsA(isA<T1YError>()),
      );
    });

    test('throws T1YError for 5xx with standard API response', () async {
      final response = http.Response(
        '{"code":500,"message":"Internal error","data":null}',
        500,
        headers: {'content-type': 'application/json'},
      );

      expect(
        () => handleResponse(
          response,
          false,
          '',
          defaultTimeFormat,
        ),
        throwsA(isA<T1YError>()),
      );
    });

    test('T1YError contains correct code and message from 4xx', () async {
      final response = http.Response(
        '{"code":403,"message":"Forbidden","data":"no"}',
        403,
        headers: {'content-type': 'application/json'},
      );

      try {
        await handleResponse(response, false, '', defaultTimeFormat);
        fail('Expected T1YError');
      } on T1YError catch (e) {
        expect(e.code, 403);
        expect(e.message, 'Forbidden');
        expect(e.data, 'no');
      }
    });

    test('throws T1YError for non-standard error response', () async {
      final response = http.Response('Server Error', 502);

      expect(
        () => handleResponse(response, false, '', defaultTimeFormat),
        throwsA(isA<T1YError>()),
      );
    });
  });

  group('handleResponse — Safe mode (encryption)', () {
    test('throws T1YError when safe mode decryption fails', () async {
      // Encrypted-looking response but with garbage data
      final response = http.Response(
        '{"n":"bad","j":"bad","t":"bad"}',
        200,
        headers: {'content-type': 'application/json'},
      );

      expect(
        () => handleResponse(
          response,
          true, // safe mode on
          'not-a-valid-32-byte-key-here!',
          defaultTimeFormat,
        ),
        throwsA(isA<T1YError>()),
      );
    });
  });

  group('handleResponse — Timestamp formatting', () {
    test('formats createdAt/updatedAt in response data', () async {
      final response = http.Response(
        '{"code":200,"message":"ok","data":{"name":"Alice","createdAt":"2024-01-15T10:30:00.000Z"}}',
        200,
        headers: {'content-type': 'application/json'},
      );

      final result = await handleResponse<Map<String, dynamic>>(
        response,
        false,
        '',
        'YYYY-MM-DD HH:mm:ss',
      );

      final data = result.data;
      expect((data as Map)['name'], 'Alice');
      // createdAt should be reformatted
      expect(data['createdAt'], isNot('2024-01-15T10:30:00.000Z'));
    });
  });

  // ==================== handleFetchError ====================

  group('handleFetchError', () {
    test('re-throws existing T1YError', () {
      final t1yError = T1YError(404, 'Not found');
      expect(
        () => handleFetchError(t1yError),
        throwsA(t1yError),
      );
    });

    test('wraps regular Exception in T1YError', () {
      expect(
        () => handleFetchError(Exception('Something went wrong')),
        throwsA(isA<T1YError>()),
      );
    });

    test('wraps unknown object in T1YError', () {
      expect(
        () => handleFetchError('weird error'),
        throwsA(isA<T1YError>()),
      );
    });
  });
}
