/// Create a Date marker string. The server converts this to a Go time.Time.
String dateMarker(String dateStr) => "Date('$dateStr')";

/// Create a DateTime marker string. Same as Date on the server side.
String dateTimeMarker(String dateStr) => "DateTime('$dateStr')";

/// Create a Timestamp marker string. The server converts this to a Unix timestamp.
String timestampMarker(dynamic unix) => "Timestamp('$unix')";
