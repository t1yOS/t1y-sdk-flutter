/// Create a Boolean marker. The server converts this to a Go bool.
String booleanMarker(bool val) => 'Boolean($val)';

/// Create an Integer marker. The server converts this to int32.
String integerMarker(num n) => 'Integer($n)';

/// Create a Bigint marker. The server converts this to int64.
String bigintMarker(num n) => 'Bigint($n)';

/// Create a Float marker. The server converts this to float32.
String floatMarker(num n) => 'Float($n)';

/// Create a Double marker. The server converts this to float64.
String doubleMarker(num n) => 'Double($n)';
