import '../utils/constants.dart';

/// Format a UTC date string to local time using the given format template.
///
/// Format tokens:
///   YYYY - 4-digit year
///   MM   - 2-digit month (01-12)
///   DD   - 2-digit day (01-31)
///   HH   - 2-digit hour (00-23)
///   mm   - 2-digit minute (00-59)
///   ss   - 2-digit second (00-59)
String formatLocalTime(String utcString, String format) {
  final date = DateTime.tryParse(utcString);
  if (date == null) return utcString;

  String pad(int n) => n.toString().padLeft(2, '0');

  return format
      .replaceAll('YYYY', date.year.toString())
      .replaceAll('MM', pad(date.month))
      .replaceAll('DD', pad(date.day))
      .replaceAll('HH', pad(date.hour))
      .replaceAll('mm', pad(date.minute))
      .replaceAll('ss', pad(date.second));
}

/// Recursively convert all `createdAt` and `updatedAt` fields in a data
/// structure from UTC strings to local time formatted strings.
///
/// Returns a new object/list; does not mutate the original.
dynamic formatTimestampsToLocal(dynamic data, [String format = defaultTimeFormat]) {
  dynamic traverse(dynamic value) {
    if (value is List) {
      return value.map(traverse).toList();
    }
    if (value is Map) {
      final Map<String, dynamic> result = {};
      for (final key in value.keys) {
        if (key == 'createdAt' || key == 'updatedAt') {
          result[key] = formatLocalTime(value[key]?.toString() ?? '', format);
        } else {
          result[key] = traverse(value[key]);
        }
      }
      return result;
    }
    return value;
  }

  return traverse(data);
}
