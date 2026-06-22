import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('HMAC-SHA256', () {
    // ==================== Basic HMAC ====================

    test('produces 64-char hex string', () {
      final hmac = hmacSHA256Hex('secret', 'message');
      expect(hmac.length, 64);
      expect(hmac, isNot(contains(' ')));
    });

    test('is deterministic', () {
      expect(
        hmacSHA256Hex('key', 'data'),
        hmacSHA256Hex('key', 'data'),
      );
    });

    test('different key produces different hash', () {
      expect(
        hmacSHA256Hex('key1', 'data'),
        isNot(hmacSHA256Hex('key2', 'data')),
      );
    });

    test('different message produces different hash', () {
      expect(
        hmacSHA256Hex('key', 'data1'),
        isNot(hmacSHA256Hex('key', 'data2')),
      );
    });

    test('empty message', () {
      final hmac = hmacSHA256Hex('secret', '');
      expect(hmac.length, 64);
    });

    test('empty key', () {
      final hmac = hmacSHA256Hex('', 'message');
      expect(hmac.length, 64);
    });

    // ==================== Verify ====================

    test('verify correct signature returns true', () {
      final secret = 'my-secret-key';
      final message = 'test-message';
      final signature = hmacSHA256Hex(secret, message);

      expect(verifyHmacSHA256(secret, message, signature), true);
    });

    test('verify incorrect signature returns false', () {
      expect(
        verifyHmacSHA256('key', 'msg', 'wrong_signature'),
        false,
      );
    });

    test('verify is case-insensitive', () {
      final secret = 'secret';
      final message = 'data';
      final upper = hmacSHA256Hex(secret, message).toUpperCase();
      final lower = hmacSHA256Hex(secret, message).toLowerCase();

      expect(verifyHmacSHA256(secret, message, upper), true);
      expect(verifyHmacSHA256(secret, message, lower), true);
    });
  });

  group('HMAC-SHA256 Pure Dart', () {
    // ==================== Pure implementation ====================

    test('produces 64-char hex string', () {
      final hmac = hmacSHA256Pure('secret', 'message');
      expect(hmac.length, 64);
    });

    test('is consistent with crypto package implementation', () {
      // Compare pure-Dart HMAC vs package:crypto HMAC
      final fromCrypto = hmacSHA256Hex('secret-key', 'the message');
      final fromPure = hmacSHA256Pure('secret-key', 'the message');

      expect(fromPure, fromCrypto);
    });

    test('is consistent with crypto package — empty message', () {
      final fromCrypto = hmacSHA256Hex('key', '');
      final fromPure = hmacSHA256Pure('key', '');

      expect(fromPure, fromCrypto);
    });

    test('is consistent with crypto package — long message', () {
      final msg = 'x' * 1000;
      final fromCrypto = hmacSHA256Hex('key', msg);
      final fromPure = hmacSHA256Pure('key', msg);

      expect(fromPure, fromCrypto);
    });

    test('handles key longer than block size (64 bytes)', () {
      final longKey = 'k' * 100;
      final hmac = hmacSHA256Pure(longKey, 'msg');
      expect(hmac.length, 64);
    });

    test('handles key exactly at block size (64 bytes)', () {
      final key = 'k' * 64;
      final hmac = hmacSHA256Pure(key, 'msg');
      expect(hmac.length, 64);
    });
  });

  // ==================== Timing-safe comparison ====================

  group('timing-safe comparison (indirect)', () {
    test('different length strings are not equal', () {
      expect(
        verifyHmacSHA256('key', 'msg', 'short'),
        false,
      );
    });

    test('same length wrong value is not equal', () {
      final wrong = '0' * 64; // same length, wrong content

      expect(verifyHmacSHA256('key', 'msg', wrong), false);
    });
  });
}
