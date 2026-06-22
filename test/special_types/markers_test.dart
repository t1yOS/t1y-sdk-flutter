import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  // ==================== ObjectID ====================
  group('objectIdMarker', () {
    test('produces valid ObjectID marker', () {
      final marker = objectIdMarker('507f1f77bcf86cd799439011');
      expect(marker, "ObjectID('507f1f77bcf86cd799439011')");
    });

    test('throws on invalid hex', () {
      expect(
        () => objectIdMarker('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws on empty string', () {
      expect(
        () => objectIdMarker(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ==================== Date/Datetime/Timestamp ====================
  group('dateMarker', () {
    test('produces Date marker', () {
      expect(dateMarker('2024-01-15'), "Date('2024-01-15')");
      expect(dateMarker('2024-01-15T10:30:00Z'), "Date('2024-01-15T10:30:00Z')");
    });
  });

  group('dateTimeMarker', () {
    test('produces DateTime marker', () {
      expect(
        dateTimeMarker('2024-06-15T14:30:00Z'),
        "DateTime('2024-06-15T14:30:00Z')",
      );
    });
  });

  group('timestampMarker', () {
    test('produces Timestamp marker', () {
      expect(timestampMarker(1705312200), "Timestamp('1705312200')");
      expect(timestampMarker(0), "Timestamp('0')");
    });

    test('handles negative values', () {
      expect(timestampMarker(-1), "Timestamp('-1')");
    });
  });

  // ==================== Numeric Markers ====================
  group('booleanMarker', () {
    test('produces Boolean marker', () {
      expect(booleanMarker(true), 'Boolean(true)');
      expect(booleanMarker(false), 'Boolean(false)');
    });
  });

  group('integerMarker', () {
    test('produces Integer marker', () {
      expect(integerMarker(42), 'Integer(42)');
      expect(integerMarker(0), 'Integer(0)');
      expect(integerMarker(-10), 'Integer(-10)');
    });
  });

  group('bigintMarker', () {
    test('produces Bigint marker', () {
      expect(bigintMarker(9007199254740991), 'Bigint(9007199254740991)');
    });
  });

  group('floatMarker', () {
    test('produces Float marker', () {
      expect(floatMarker(4.5), 'Float(4.5)');
      expect(floatMarker(0.0), 'Float(0.0)');
    });
  });

  group('doubleMarker', () {
    test('produces Double marker', () {
      expect(doubleMarker(3.141592653589793), 'Double(3.141592653589793)');
    });
  });

  // ==================== Structured Markers ====================
  group('arrayMarker', () {
    test('produces Array marker with JSON', () {
      expect(arrayMarker(['a', 'b']), 'Array(["a","b"])');
    });

    test('handles empty array', () {
      expect(arrayMarker([]), 'Array([])');
    });

    test('handles nested arrays', () {
      final marker = arrayMarker([
        [1, 2],
        [3, 4],
      ]);
      expect(marker, 'Array([[1,2],[3,4]])');
    });
  });

  group('mapMarker', () {
    test('produces Map marker with JSON', () {
      expect(mapMarker({'key': 'val'}), 'Map({"key":"val"})');
    });

    test('handles empty map', () {
      expect(mapMarker({}), 'Map({})');
    });
  });

  group('mapArrayMarker', () {
    test('produces Map[] marker', () {
      final marker = mapArrayMarker([
        {'a': 1},
      ]);
      expect(marker, 'Map[]([{"a":1}])');
    });

    test('handles empty array', () {
      expect(mapArrayMarker([]), 'Map[]([])');
    });

    test('handles multiple maps', () {
      final marker = mapArrayMarker([
        {'a': 1},
        {'b': 2},
      ]);
      expect(marker, 'Map[]([{"a":1},{"b":2}])');
    });
  });

  // ==================== Null Markers ====================
  group('null markers', () {
    test('null markers are correct constants', () {
      expect(nullValue, 'Null');
      expect(noneValue, 'None');
      expect(nilValue, 'Nil');
      expect(emptyValue, '');
      expect(undefinedUpper, 'UNDEFINED');
      expect(undefinedValue, 'Undefined');
    });
  });

  // ==================== Time Helpers ====================
  group('timeNow', () {
    test('all markers are correct', () {
      expect(timeNow.now(), 'time.Now()');
      expect(timeNow.nowUnix(), 'time.Now().Unix()');
      expect(timeNow.nowUnixNano(), 'time.Now().UnixNano()');
      expect(timeNow.nowWeekday(), 'time.Now().Weekday()');
      expect(timeNow.nowWeekdayChinese(), 'time.Now().Weekday().Chinese()');
    });

    test('const instance works', () {
      expect(const TimeNow().now(), 'time.Now()');
    });
  });
}
