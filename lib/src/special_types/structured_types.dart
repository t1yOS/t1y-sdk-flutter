import 'dart:convert';

/// Create an Array marker. The server converts this to a Go slice.
String arrayMarker(List<dynamic> arr) => 'Array(${jsonEncode(arr)})';

/// Create a Map marker. The server converts this to a map[string]interface{}.
String mapMarker(Map<String, dynamic> obj) => 'Map(${jsonEncode(obj)})';

/// Create a Map[] marker. The server converts this to []map[string]interface{}.
String mapArrayMarker(List<Map<String, dynamic>> arr) =>
    'Map[](${jsonEncode(arr)})';
