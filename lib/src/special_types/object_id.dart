import '../utils/constants.dart';

/// Create an ObjectID marker string that the server will convert to a MongoDB ObjectID.
///
/// Returns ObjectID marker string, e.g. `ObjectID('507f1f77bcf86cd799439011')`
String objectIdMarker(String id) {
  if (!objectIdPattern.hasMatch(id)) {
    throw ArgumentError('Invalid ObjectID: "$id" (must be 24 hex characters)');
  }
  return "ObjectID('$id')";
}
