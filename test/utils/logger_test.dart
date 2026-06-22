import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('T1YLogger', () {
    // We test the logger behavior by installing a custom handler
    // and verifying messages are received correctly.

    List<Map<String, dynamic>> captured = [];

    setUp(() {
      captured = [];
      T1YLogger.setHandler((level, message, [error]) {
        captured.add({
          'level': level,
          'message': message,
          'error': error,
        });
      });
    });

    tearDown(() {
      // Restore default (no handler — uses dart:developer)
      T1YLogger.setHandler(null);
      T1YLogger.setLevel(T1YLogLevel.warning); // default
    });

    test('warning and error messages are captured (default level)', () {
      T1YLogger.warning('warning msg');
      T1YLogger.error('error msg');

      expect(captured.length, 2);
      expect(captured[0]['level'], T1YLogLevel.warning);
      expect(captured[0]['message'], 'warning msg');
      expect(captured[1]['level'], T1YLogLevel.error);
      expect(captured[1]['message'], 'error msg');
    });

    test('debug and info are filtered out at default level (warning)', () {
      T1YLogger.debug('debug msg');
      T1YLogger.info('info msg');
      T1YLogger.warning('warning msg');

      expect(captured.length, 1);
      expect(captured[0]['level'], T1YLogLevel.warning);
    });

    test('debug messages pass through when level is debug', () {
      T1YLogger.setLevel(T1YLogLevel.debug);

      T1YLogger.debug('debug msg');
      T1YLogger.info('info msg');
      T1YLogger.warning('warning msg');
      T1YLogger.error('error msg');

      expect(captured.length, 4);
    });

    test('only error messages pass through at error level', () {
      T1YLogger.setLevel(T1YLogLevel.error);

      T1YLogger.warning('warning');
      T1YLogger.error('error');

      expect(captured.length, 1);
      expect(captured[0]['level'], T1YLogLevel.error);
    });

    test('error object is passed through', () {
      final err = Exception('boom');
      T1YLogger.error('something failed', err);

      expect(captured.length, 1);
      expect(captured[0]['error'], err);
    });

    test('error object is null when not provided', () {
      T1YLogger.warning('just a warning');

      expect(captured.length, 1);
      expect(captured[0]['error'], isNull);
    });

    test('setHandler to null restores default (no-op from test perspective)', () {
      T1YLogger.setHandler(null);
      // Should not throw — uses dart:developer log internally
      T1YLogger.warning('test');
      expect(captured, isEmpty); // our captured is empty since handler removed
    });
  });
}
