// Recursively convert DateTime objects and large timestamp numbers
// into the marker string format that the server's GetDataTypes() recognizes.
//
// - DateTime objects → `Date('ISO-8601')`
// - int >= 10 digits → `Timestamp('unix')`

dynamic convertDateTypes(dynamic value) {
  if (value is DateTime) {
    return "Date('${value.toUtc().toIso8601String()}')";
  }

  if (value is int) {
    final str = value.toString();
    // 10+ digit integer → Timestamp
    if (str.length >= 10) {
      return "Timestamp('$str')";
    }
    return value;
  }

  if (value is List) {
    return value.map((v) => convertDateTypes(v)).toList();
  }

  if (value is Map) {
    final Map<String, dynamic> obj = {};
    for (final key in value.keys) {
      obj[key.toString()] = convertDateTypes(value[key]);
    }
    return obj;
  }

  return value;
}

/// Check if a value is a non-null, non-list Map with at least one key.
bool isNonEmptyObject(dynamic value) {
  return value is Map && value.isNotEmpty;
}

/// Check if a value is a plain Map (non-null, non-list).
bool isPlainObject(dynamic value) {
  return value is Map;
}

/// Check if a value is a non-empty list where every element is a non-empty Map.
bool isNonEmptyListWithNonEmptyObjects(dynamic value) {
  if (value is! List || value.isEmpty) return false;
  return value.every(
    (item) => item is Map && item.isNotEmpty,
  );
}
