import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('createSignature', () {
    test('produces 64-char hex string', () {
      final signature = createSignature(SignatureInput(
        method: 'POST',
        pathAndQuery: '/v5/classes/users',
        body: '{"name":"Alice"}',
        appId: 1001,
        timestamp: 1705312200,
        secretKey: 's' * 32,
      ));
      expect(signature.length, 64);
    });

    test('is deterministic', () {
      final input = SignatureInput(
        method: 'GET',
        pathAndQuery: '/v5/classes/users/test',
        body: '',
        appId: 1001,
        timestamp: 1705312200,
        secretKey: 'k' * 32,
      );

      expect(createSignature(input), createSignature(input));
    });

    test('different method produces different signature', () {
      final base = SignatureInput(
        method: 'GET',
        pathAndQuery: '/test',
        body: '',
        appId: 1001,
        timestamp: 1000,
        secretKey: 'k' * 32,
      );

      final getSig = createSignature(base);
      final postSig = createSignature(SignatureInput(
        method: 'POST',
        pathAndQuery: base.pathAndQuery,
        body: base.body,
        appId: base.appId,
        timestamp: base.timestamp,
        secretKey: base.secretKey,
      ));

      expect(getSig, isNot(postSig));
    });

    test('different path produces different signature', () {
      final secretKey = 's' * 32;
      final sig1 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/a', body: '',
        appId: 1, timestamp: 1, secretKey: secretKey,
      ));
      final sig2 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/b', body: '',
        appId: 1, timestamp: 1, secretKey: secretKey,
      ));

      expect(sig1, isNot(sig2));
    });

    test('different body produces different signature', () {
      final secretKey = 's' * 32;
      final sig1 = createSignature(SignatureInput(
        method: 'POST', pathAndQuery: '/', body: 'a',
        appId: 1, timestamp: 1, secretKey: secretKey,
      ));
      final sig2 = createSignature(SignatureInput(
        method: 'POST', pathAndQuery: '/', body: 'b',
        appId: 1, timestamp: 1, secretKey: secretKey,
      ));

      expect(sig1, isNot(sig2));
    });

    test('different appId produces different signature', () {
      final secretKey = 's' * 32;
      final sig1 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/', body: '',
        appId: 1001, timestamp: 1, secretKey: secretKey,
      ));
      final sig2 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/', body: '',
        appId: 1002, timestamp: 1, secretKey: secretKey,
      ));

      expect(sig1, isNot(sig2));
    });

    test('different timestamp produces different signature', () {
      final secretKey = 's' * 32;
      final sig1 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/', body: '',
        appId: 1, timestamp: 1000, secretKey: secretKey,
      ));
      final sig2 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/', body: '',
        appId: 1, timestamp: 2000, secretKey: secretKey,
      ));

      expect(sig1, isNot(sig2));
    });

    test('different secret key produces different signature', () {
      final sig1 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/', body: '',
        appId: 1, timestamp: 1, secretKey: 'a' * 32,
      ));
      final sig2 = createSignature(SignatureInput(
        method: 'GET', pathAndQuery: '/', body: '',
        appId: 1, timestamp: 1, secretKey: 'b' * 32,
      ));

      expect(sig1, isNot(sig2));
    });
  });

  group('getSafeTimestamp', () {
    test('returns a numeric string', () {
      final ts = getSafeTimestamp(0);
      expect(int.tryParse(ts), isNotNull);
    });

    test('offset is applied', () {
      final ts0 = getSafeTimestamp(0);
      final ts100 = getSafeTimestamp(100);

      final diff = int.parse(ts100) - int.parse(ts0);
      expect(diff, 100);
    });

    test('negative offset is applied', () {
      final ts0 = getSafeTimestamp(0);
      final tsNeg = getSafeTimestamp(-50);

      final diff = int.parse(tsNeg) - int.parse(ts0);
      expect(diff, -50);
    });
  });
}
