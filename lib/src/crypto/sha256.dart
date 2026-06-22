import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Compute the SHA-256 hash of a string and return the hex digest.
String sha256Hex(String data) {
  final bytes = utf8.encode(data);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Compute SHA-256 of raw bytes and return hex digest.
String sha256RawBytesHex(List<int> bytes) {
  final digest = sha256.convert(Uint8List.fromList(bytes));
  return digest.toString();
}
