import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';

import '../types/api_types.dart';

/// GCM authentication tag length in bytes
const int aesGcmTagLength = 16;

/// AES-GCM nonce/IV length in bytes
const int aesGcmNonceLength = 12;

/// Encrypt data using AES-256-GCM.
///
/// Returns JSON string of { n, j, t } payload matching the Go server format.
String encryptAESGCM(String data, Uint8List keyBytes) {
  if (keyBytes.length != 32) {
    throw ArgumentError('Key length must be 32 bytes for AES-256-GCM');
  }

  // Generate random nonce
  final nonce = Uint8List(aesGcmNonceLength);
  final rng = Random.secure();
  for (int i = 0; i < aesGcmNonceLength; i++) {
    nonce[i] = rng.nextInt(256);
  }

  final plaintext = utf8.encode(data);

  // Initialize AES-GCM cipher
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      true,
      AEADParameters(
        KeyParameter(keyBytes),
        128, // macSize in bits
        nonce,
        Uint8List(0), // associatedData
      ),
    );

  // Encrypt — processBytes writes ciphertext, doFinal appends tag
  final outputSize = cipher.getOutputSize(plaintext.length);
  final encrypted = Uint8List(outputSize);
  final processedLen =
      cipher.processBytes(Uint8List.fromList(plaintext), 0, plaintext.length, encrypted, 0);
  final finalLen = cipher.doFinal(encrypted, processedLen);
  final totalLen = processedLen + finalLen;

  // Slice the exact output: [ciphertext (plaintext.length bytes)] || [tag (16 bytes)]
  final ciphertext = encrypted.sublist(0, totalLen - aesGcmTagLength);
  final tag = encrypted.sublist(totalLen - aesGcmTagLength, totalLen);

  final payload = AESGCMPayload(
    n: base64Encode(nonce),
    j: base64Encode(ciphertext),
    t: base64Encode(tag),
  );

  return jsonEncode(payload.toJson());
}

/// Decrypt data using AES-256-GCM.
///
/// Expects JSON string of { n, j, t } payload and returns plaintext.
String decryptAESGCM(String jsonPayload, Uint8List keyBytes) {
  if (keyBytes.length != 32) {
    throw ArgumentError('Key length must be 32 bytes for AES-256-GCM');
  }

  final payload = AESGCMPayload.fromJson(
    jsonDecode(jsonPayload) as Map<String, dynamic>,
  );

  final nonce = base64Decode(payload.n);
  final ciphertext = base64Decode(payload.j);
  final tag = base64Decode(payload.t);

  // Concatenate ciphertext + tag
  final sealed = Uint8List(ciphertext.length + tag.length);
  sealed.setAll(0, ciphertext);
  sealed.setAll(ciphertext.length, tag);

  // Initialize AES-GCM cipher for decryption
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(
        KeyParameter(keyBytes),
        128, // macSize in bits
        Uint8List.fromList(nonce),
        Uint8List(0), // associatedData
      ),
    );

  // Decrypt — processBytes reverses encryption, doFinal verifies tag
  final outputSize = cipher.getOutputSize(sealed.length);
  final decrypted = Uint8List(outputSize);
  final processedLen =
      cipher.processBytes(sealed, 0, sealed.length, decrypted, 0);
  final finalLen = cipher.doFinal(decrypted, processedLen);

  return utf8.decode(decrypted.sublist(0, processedLen + finalLen));
}
