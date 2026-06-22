import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('convertDateTypes', () {
    test('converts DateTime to Date marker', () {
      final dt = DateTime.utc(2024, 6, 15, 14, 30);
      final result = convertDateTypes(dt);
      expect(result, startsWith("Date('"));
      expect(result, contains('2024-06-15T14:30:00.000Z'));
    });

    test('converts large int (10+ digits) to Timestamp marker', () {
      expect(convertDateTypes(1705312200), "Timestamp('1705312200')");
      expect(convertDateTypes(1000000000), "Timestamp('1000000000')");
    });

    test('does not convert small ints (less than 10 digits)', () {
      expect(convertDateTypes(42), 42);
      expect(convertDateTypes(999999999), 999999999);
      expect(convertDateTypes(-1), -1);
    });

    test('returns non-DateTime, non-int values unchanged', () {
      expect(convertDateTypes('hello'), 'hello');
      expect(convertDateTypes(3.14), 3.14);
      expect(convertDateTypes(true), true);
      expect(convertDateTypes(null), null);
    });

    test('recursively converts List items', () {
      final input = [
        DateTime.utc(2024, 1, 15),
        'string',
        1705312200,
        42,
      ];
      final result = convertDateTypes(input) as List;

      expect(result[0], startsWith("Date('"));
      expect(result[1], 'string');
      expect(result[2], "Timestamp('1705312200')");
      expect(result[3], 42);
    });

    test('recursively converts Map values', () {
      final input = {
        'createdAt': DateTime.utc(2024, 1, 15),
        'name': 'Alice',
        'timestamp': 1705312200,
        'age': 30,
      };
      final result = convertDateTypes(input) as Map;

      expect(result['createdAt'], startsWith("Date('"));
      expect(result['name'], 'Alice');
      expect(result['timestamp'], "Timestamp('1705312200')");
      expect(result['age'], 30);
    });

    test('deeply nested structures', () {
      final input = {
        'items': [
          {'time': DateTime.utc(2024, 1, 15), 'ts': 1705312200},
        ],
      };
      final result = convertDateTypes(input) as Map;
      final items = result['items'] as List;
      final first = items[0] as Map;

      expect(first['time'], startsWith("Date('"));
      expect(first['ts'], "Timestamp('1705312200')");
    });

    test('empty list', () {
      final result = convertDateTypes([]);
      expect(result, []);
    });

    test('empty map', () {
      final result = convertDateTypes({});
      expect(result, {});
    });
  });

  // ==================== Object Checks ====================

  group('isNonEmptyObject', () {
    test('true for non-empty Map', () {
      expect(isNonEmptyObject({'a': 1}), true);
      expect(isNonEmptyObject({0: 'val'}), true);
    });

    test('false for empty Map', () {
      expect(isNonEmptyObject({}), false);
    });

    test('false for List (even non-empty)', () {
      expect(isNonEmptyObject([1, 2, 3]), false);
      expect(isNonEmptyObject([]), false);
    });

    test('false for String', () {
      expect(isNonEmptyObject('hello'), false);
      expect(isNonEmptyObject(''), false);
    });

    test('false for null', () {
      expect(isNonEmptyObject(null), false);
    });

    test('false for primitive types', () {
      expect(isNonEmptyObject(42), false);
      expect(isNonEmptyObject(true), false);
      expect(isNonEmptyObject(3.14), false);
    });
  });

  group('isPlainObject', () {
    test('true for any Map', () {
      expect(isPlainObject({'a': 1}), true);
      expect(isPlainObject({}), true);
    });

    test('false for non-Map', () {
      expect(isPlainObject([]), false);
      expect(isPlainObject(null), false);
      expect(isPlainObject('str'), false);
      expect(isPlainObject(42), false);
    });
  });

  group('isNonEmptyListWithNonEmptyObjects', () {
    test('true for list of non-empty Maps', () {
      expect(isNonEmptyListWithNonEmptyObjects([{'a': 1}]), true);
      expect(
        isNonEmptyListWithNonEmptyObjects([
          {'a': 1},
          {'b': 2},
        ]),
        true,
      );
    });

    test('false for empty list', () {
      expect(isNonEmptyListWithNonEmptyObjects([]), false);
    });

    test('false when any element is an empty Map', () {
      expect(isNonEmptyListWithNonEmptyObjects([{}]), false);
      expect(
        isNonEmptyListWithNonEmptyObjects([
          {'a': 1},
          {},
        ]),
        false,
      );
    });

    test('false when any element is not a Map', () {
      expect(isNonEmptyListWithNonEmptyObjects(['string']), false);
      expect(
        isNonEmptyListWithNonEmptyObjects([
          {'a': 1},
          42,
        ]),
        false,
      );
    });

    test('false for non-List', () {
      expect(isNonEmptyListWithNonEmptyObjects('string'), false);
      expect(isNonEmptyListWithNonEmptyObjects({'a': 1}), false);
      expect(isNonEmptyListWithNonEmptyObjects(null), false);
    });
  });
}
