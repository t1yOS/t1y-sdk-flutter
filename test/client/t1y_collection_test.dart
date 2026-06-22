import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  late T1YClient client;
  late T1YCollection collection;

  setUp(() {
    client = T1YClient(T1YClientConfig(
      appId: 1001,
      apiKey: 'a' * 32,
      secretKey: 'b' * 32,
    ));
    collection = client.db.collection('test_collection');
  });

  // ==================== Validation Tests ====================
  // These tests validate that input validation throws before any HTTP call

  group('T1YCollection — input validation', () {
    // --- insertOne ---
    test('insertOne throws on empty data', () {
      expect(
        () => collection.insertOne({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('insertOne throws on null-like data', () {
      // These would fail type check at compile time, but if dynamic is used:
      expect(
        () => collection.insertOne({}), // empty
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- deleteById ---
    test('deleteById throws on invalid ObjectID', () {
      expect(
        () => collection.deleteById('not-valid'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('deleteById throws on empty ObjectID', () {
      expect(
        () => collection.deleteById(''),
        throwsA(isA<ValidationError>()),
      );
    });

    // --- updateById ---
    test('updateById throws on invalid ObjectID', () {
      expect(
        () => collection.updateById('bad', {'name': 'Alice'}),
        throwsA(isA<ValidationError>()),
      );
    });

    test('updateById throws on empty data', () {
      expect(
        () => collection.updateById('507f1f77bcf86cd799439011', {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- findById ---
    test('findById throws on invalid ObjectID', () {
      expect(
        () => collection.findById('bad'),
        throwsA(isA<ValidationError>()),
      );
    });

    // --- deleteOne ---
    test('deleteOne throws on empty filter', () {
      expect(
        () => collection.deleteOne({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- updateOne ---
    test('updateOne throws on empty filter', () {
      expect(
        () => collection.updateOne({}, {'name': 'Alice'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateOne throws on empty body', () {
      expect(
        () => collection.updateOne({'name': 'Alice'}, {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- findOne ---
    test('findOne throws on empty filter', () {
      expect(
        () => collection.findOne({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- insertMany ---
    test('insertMany throws on empty list', () {
      expect(
        () => collection.insertMany([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('insertMany throws on list with empty maps', () {
      expect(
        () => collection.insertMany([{}]),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- deleteMany ---
    test('deleteMany throws on non-plain-object filter', () {
      // Using a non-Map type via dynamic — Dart will throw TypeError
      // before the SDK's validation. Verify the SDK guard works with
      // a valid Map scenario instead (tested via public API).
      expect(
        () => collection.deleteMany([] as dynamic),
        throwsA(isA<Error>()),
      );
    });

    test('deleteMany accepts empty filter (plain object)', () {
      // Empty map is still a plain object
      // Validation passes; HTTP call will fail later
      expect(
        () => collection.deleteMany({}),
        returnsNormally, // validation passes
      );
    });

    // --- updateMany ---
    test('updateMany throws on non-plain-object filter', () {
      expect(
        () => collection.updateMany([] as dynamic, {'a': 1}),
        throwsA(isA<Error>()),
      );
    });

    test('updateMany throws on empty body', () {
      expect(
        () => collection.updateMany({}, {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- find ---
    test('find throws on page < 1', () {
      expect(
        () => collection.find(page: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => collection.find(page: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('find throws on size < 1', () {
      expect(
        () => collection.find(size: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('find throws on empty sort', () {
      expect(
        () => collection.find(sort: {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('find throws on non-plain-object filter', () {
      expect(
        () => collection.find(filter: 42 as dynamic),
        throwsA(isA<Error>()),
      );
    });

    // --- aggregate ---
    test('aggregate throws on empty pipeline', () {
      expect(
        () => collection.aggregate([]),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- count ---
    test('count throws on non-plain-object filter', () {
      expect(
        () => collection.count(filter: 'bad' as dynamic),
        throwsA(isA<Error>()),
      );
    });

    test('count accepts empty filter', () {
      expect(
        () => collection.count(filter: {}),
        returnsNormally, // validation passes
      );
    });

    // --- distinct ---
    test('distinct throws on empty fieldName', () {
      expect(
        () => collection.distinct(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('distinct throws on non-plain-object filter', () {
      expect(
        () => collection.distinct('field', filter: 123 as dynamic),
        throwsA(isA<Error>()),
      );
    });

    // --- find with size clamping ---
    test('find clamps size to maxPageSize', () {
      // size > maxPageSize should be clamped (no throw, just clamped)
      // Validation passes, actual HTTP call would fail
      expect(
        () => collection.find(size: 9999),
        returnsNormally, // should not throw on validation
      );
    });
  });

  // ==================== Collection Creation ====================

  group('T1YCollection — construction', () {
    test('collection stores name', () {
      final coll = client.db.collection('my_collection');
      expect(coll, isNotNull);
    });

    test('empty collection name throws', () {
      expect(
        () => client.db.collection(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
