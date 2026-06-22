import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'sha256.dart';

/// Compute HMAC-SHA256 and return hex digest.
///
/// This is intentionally synchronous because it's called in the request
/// signing path, which must be fast.
String hmacSHA256Hex(String secret, String message) {
  final key = utf8.encode(secret);
  final msg = utf8.encode(message);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(msg);
  return digest.toString();
}

/// Verify an HMAC-SHA256 signature using constant-time comparison.
bool verifyHmacSHA256(String secret, String message, String signature) {
  final expected = hmacSHA256Hex(secret, message);
  return _timingSafeEqual(expected, signature.toLowerCase());
}

/// Constant-time string comparison
bool _timingSafeEqual(String a, String b) {
  if (a.length != b.length) return false;
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}

// ==================== Pure-Dart HMAC-SHA256 (fallback) ====================

/// HMAC-SHA256 using pure-Dart SHA-256 (byte-oriented).
///
/// Implements: HMAC(K, m) = H((K' XOR opad) || H((K' XOR ipad) || m))
String hmacSHA256Pure(String secret, String message) {
  const blockSize = 64;

  List<int> keyBytes = utf8.encode(secret);
  final msgBytes = utf8.encode(message);

  // If key is longer than block size, hash it first
  if (keyBytes.length > blockSize) {
    keyBytes = _hexToBytes(sha256RawBytesHex(keyBytes));
  }

  // Pad key to block size
  final paddedKey = List<int>.filled(blockSize, 0);
  for (int i = 0; i < keyBytes.length && i < blockSize; i++) {
    paddedKey[i] = keyBytes[i];
  }

  // Compute inner: H((key XOR ipad) || message)
  final ipad = List<int>.filled(blockSize, 0x36);
  final innerKey = _xorBytes(paddedKey, ipad);
  final innerData = [...innerKey, ...msgBytes];
  final innerHash = _hexToBytes(sha256RawBytesHex(innerData));

  // Compute outer: H((key XOR opad) || innerHash)
  final opad = List<int>.filled(blockSize, 0x5c);
  final outerKey = _xorBytes(paddedKey, opad);
  final outerData = [...outerKey, ...innerHash];

  return sha256RawBytesHex(outerData);
}

/// XOR two byte lists (must be same length)
List<int> _xorBytes(List<int> a, List<int> b) {
  final result = List<int>.filled(a.length, 0);
  for (int i = 0; i < a.length; i++) {
    result[i] = a[i] ^ b[i];
  }
  return result;
}

/// Convert hex string to byte list
List<int> _hexToBytes(String hex) {
  final bytes = <int>[];
  for (int i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return bytes;
}
