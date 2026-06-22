import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('T1YError', () {
    test('stores code, message, and data', () {
      final error = T1YError(404, 'Not found', {'id': 1});
      expect(error.code, 404);
      expect(error.message, 'Not found');
      expect(error.data, {'id': 1});
    });

    test('data is optional', () {
      final error = T1YError(500, 'Server error');
      expect(error.code, 500);
      expect(error.message, 'Server error');
      expect(error.data, isNull);
    });

    test('toString includes code and message', () {
      final error = T1YError(400, 'Bad request');
      final str = error.toString();
      expect(str, contains('400'));
      expect(str, contains('Bad request'));
    });

    test('toJson includes name, code, message, data', () {
      final error = T1YError(403, 'Forbidden', 'no access');
      final json = error.toJson();
      expect(json['name'], 'T1YError');
      expect(json['code'], 403);
      expect(json['message'], 'Forbidden');
      expect(json['data'], 'no access');
    });

    test('toJson with null data', () {
      final error = T1YError(500, 'Oops');
      final json = error.toJson();
      expect(json['data'], isNull);
    });

    test('implements Exception', () {
      final error = T1YError(0, 'test');
      expect(error, isA<Exception>());
    });
  });

  group('ValidationError', () {
    test('stores message', () {
      final error = ValidationError('appId must be >= 1001');
      expect(error.message, 'appId must be >= 1001');
    });

    test('toString includes message', () {
      final error = ValidationError('Invalid value');
      expect(error.toString(), contains('Invalid value'));
    });

    test('implements Exception', () {
      final error = ValidationError('test');
      expect(error, isA<Exception>());
    });
  });
}
