// Time helper markers that the server evaluates at request time.
//
// These are string values that, when sent to the server, are replaced
// with the actual current time on the server side via Go's time.Now().

/// Server fills in time.Now() (current UTC time)
const String timeNowMarker = 'time.Now()';

/// Server fills in time.Now().Unix() (current Unix timestamp)
const String timeNowUnixMarker = 'time.Now().Unix()';

/// Server fills in time.Now().UnixNano()
const String timeNowUnixNanoMarker = 'time.Now().UnixNano()';

/// Server fills in time.Now().Weekday() (e.g., time.Monday)
const String timeNowWeekdayMarker = 'time.Now().Weekday()';

/// Server fills in time.Now().Weekday().Chinese() (Chinese weekday name)
const String timeNowWeekdayChineseMarker = 'time.Now().Weekday().Chinese()';

/// Convenience class grouping all time-now helpers.
class TimeNow {
  const TimeNow();

  /// Server fills in time.Now()
  String now() => timeNowMarker;

  /// Server fills in time.Now().Unix()
  String nowUnix() => timeNowUnixMarker;

  /// Server fills in time.Now().UnixNano()
  String nowUnixNano() => timeNowUnixNanoMarker;

  /// Server fills in time.Now().Weekday()
  String nowWeekday() => timeNowWeekdayMarker;

  /// Server fills in time.Now().Weekday().Chinese()
  String nowWeekdayChinese() => timeNowWeekdayChineseMarker;
}

/// Convenience instance grouping all time-now helpers.
const TimeNow timeNow = TimeNow();
