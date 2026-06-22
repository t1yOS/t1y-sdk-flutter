import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('SHA-256', () {
    // ==================== sha256Hex ====================

    test('produces 64-char hex string', () {
      final hash = sha256Hex('hello');
      expect(hash.length, 64);
    });

    test('is deterministic', () {
      expect(sha256Hex('test'), sha256Hex('test'));
    });

    test('different inputs produce different hashes', () {
      expect(sha256Hex('hello'), isNot(sha256Hex('world')));
    });

    test('empty string produces valid hash', () {
      final hash = sha256Hex('');
      expect(hash.length, 64);
      // Known SHA-256 of empty string
      expect(
        hash,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('known hash — "abc"', () {
      final hash = sha256Hex('abc');
      expect(
        hash,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('unicode characters', () {
      final hash = sha256Hex('你好');
      expect(hash.length, 64);
      expect(hash, sha256Hex('你好')); // deterministic
    });

    // ==================== sha256RawBytesHex ====================

    test('produces 64-char hex from raw bytes', () {
      final hash = sha256RawBytesHex([0x00, 0x01, 0x02, 0x03]);
      expect(hash.length, 64);
    });

    test('matches sha256Hex for equivalent string input', () {
      final str = 'test data';
      final bytes = str.codeUnits;

      expect(sha256RawBytesHex(bytes), sha256Hex(str));
    });

    test('empty bytes produces valid hash', () {
      final hash = sha256RawBytesHex([]);
      expect(hash.length, 64);
      expect(
        hash,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });
  });
}
