import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  // 32-byte key for AES-256
  final key32 = Uint8List.fromList(utf8.encode('0123456789abcdef0123456789abcdef'));

  group('AES-256-GCM', () {
    // ==================== Round-trip ====================

    test('encrypt then decrypt should return original plaintext', () {
      const plaintext = 'Hello, t1yOS! This is a test message.';

      final encrypted = encryptAESGCM(plaintext, key32);
      final decrypted = decryptAESGCM(encrypted, key32);

      expect(decrypted, plaintext);
    });

    test('round-trip with empty string', () {
      const plaintext = '';

      final encrypted = encryptAESGCM(plaintext, key32);
      final decrypted = decryptAESGCM(encrypted, key32);

      expect(decrypted, plaintext);
    });

    test('round-trip with unicode characters', () {
      const plaintext = '你好，世界！🌍 — Unicode test';

      final encrypted = encryptAESGCM(plaintext, key32);
      final decrypted = decryptAESGCM(encrypted, key32);

      expect(decrypted, plaintext);
    });

    test('round-trip with JSON payload', () {
      const plaintext = '{"name":"Alice","age":30,"tags":["a","b"]}';

      final encrypted = encryptAESGCM(plaintext, key32);
      final decrypted = decryptAESGCM(encrypted, key32);

      expect(decrypted, plaintext);
    });

    test('round-trip with long payload', () {
      final plaintext = 'x' * 10000;

      final encrypted = encryptAESGCM(plaintext, key32);
      final decrypted = decryptAESGCM(encrypted, key32);

      expect(decrypted, plaintext);
    });

    test('each encryption produces different ciphertext (random nonce)', () {
      const plaintext = 'same message';

      final enc1 = encryptAESGCM(plaintext, key32);
      final enc2 = encryptAESGCM(plaintext, key32);

      // Different nonce means different output each time
      expect(enc1, isNot(enc2));
    });

    // ==================== Key validation ====================

    test('throws on key shorter than 32 bytes', () {
      final shortKey = Uint8List(16);
      expect(
        () => encryptAESGCM('test', shortKey),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => decryptAESGCM('{"n":"a","j":"b","t":"c"}', shortKey),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on key longer than 32 bytes', () {
      final longKey = Uint8List(64);
      expect(
        () => encryptAESGCM('test', longKey),
        throwsA(isA<ArgumentError>()),
      );
    });

    // ==================== Tampering detection ====================

    test('decrypt with wrong key throws', () {
      const plaintext = 'secret message';
      // exactly 32 bytes, different from key32
      final wrongKey = Uint8List.fromList(utf8.encode('A' * 32));

      final encrypted = encryptAESGCM(plaintext, key32);

      expect(
        () => decryptAESGCM(encrypted, wrongKey),
        throwsA(isA<Exception>()),
      );
    });
  });
}
