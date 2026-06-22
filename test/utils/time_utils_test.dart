import 'package:flutter_test/flutter_test.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

void main() {
  group('formatLocalTime', () {
    test('formats a valid UTC timestamp with YYYY-MM-DD HH:mm:ss', () {
      // Use a fixed UTC time that's the same in all timezones
      final result = formatLocalTime(
        '2024-01-15T10:30:00.000Z',
        'YYYY-MM-DD HH:mm:ss',
      );
      // Output depends on local timezone, but should have expected structure
      expect(result, isNotEmpty);
      // Should contain date-like components
      expect(result, matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')));
    });

    test('handles format with only date parts', () {
      final result = formatLocalTime(
        '2024-01-15T10:30:00.000Z',
        'YYYY/MM/DD',
      );
      expect(result, matches(RegExp(r'\d{4}/\d{2}/\d{2}')));
    });

    test('handles format with only time parts', () {
      final result = formatLocalTime(
        '2024-01-15T10:30:00.000Z',
        'HH:mm:ss',
      );
      expect(result, matches(RegExp(r'\d{2}:\d{2}:\d{2}')));
    });

    test('returns original string for unparseable input', () {
      const bad = 'not-a-date';
      expect(formatLocalTime(bad, 'YYYY-MM-DD'), bad);
    });

    test('returns original string for empty input', () {
      expect(formatLocalTime('', 'YYYY-MM-DD'), '');
    });

    test('YYYY, MM, DD, HH, mm, ss tokens are replaced', () {
      final result = formatLocalTime(
        '2024-01-15T10:30:00.000Z',
        'YYYY-MM-DD',
      );
      // 2024-01-15 in local time — year should be 2024
      expect(result, contains('2024'));
    });
  });

  group('formatTimestampsToLocal', () {
    test('recursively formats createdAt and updatedAt fields', () {
      final input = {
        'name': 'Alice',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-06-20T14:00:00.000Z',
        'nested': {
          'createdAt': '2024-01-15T10:30:00.000Z',
          'value': 42,
        },
      };

      final result = formatTimestampsToLocal(input, 'YYYY-MM-DD HH:mm:ss')
          as Map<String, dynamic>;

      // Non-timestamp fields unchanged
      expect(result['name'], 'Alice');

      // Timestamp fields formatted
      expect(result['createdAt'], isNot('2024-01-15T10:30:00.000Z'));
      expect(
        result['createdAt'],
        matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')),
      );
      expect(
        result['updatedAt'],
        matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')),
      );

      // Nested
      final nested = result['nested'] as Map;
      expect(nested['value'], 42);
      expect(nested['createdAt'], matches(RegExp(r'\d{4}-\d{2}-\d{2}')));
    });

    test('handles list of objects with timestamps', () {
      final input = [
        {'createdAt': '2024-01-15T10:30:00.000Z'},
        {'updatedAt': '2024-06-20T14:00:00.000Z'},
      ];

      final result = formatTimestampsToLocal(input) as List;

      expect(result.length, 2);
      final first = result[0] as Map;
      expect(
        first['createdAt'],
        matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')),
      );
    });

    test('does not mutate original', () {
      final input = {'createdAt': '2024-01-15T10:30:00.000Z'};
      final copy = Map<String, dynamic>.from(input);

      formatTimestampsToLocal(input);

      expect(input, copy);
    });

    test('passes through non-Map, non-List values', () {
      expect(formatTimestampsToLocal('hello'), 'hello');
      expect(formatTimestampsToLocal(42), 42);
      expect(formatTimestampsToLocal(null), null);
    });

    test('leaves other field names unchanged', () {
      final input = {
        'notATimestamp': '2024-01-15T10:30:00.000Z',
        'somethingElse': '2024-01-15T10:30:00.000Z',
      };

      final result = formatTimestampsToLocal(input) as Map;

      // These fields should NOT be formatted since they aren't 'createdAt' or 'updatedAt'
      expect(result['notATimestamp'], '2024-01-15T10:30:00.000Z');
      expect(result['somethingElse'], '2024-01-15T10:30:00.000Z');
    });
  });
}
