// t1yOS Serverless Platform Flutter/Dart SDK
//
// Cloud database, metadata, and cloud functions client for the t1yOS platform.
//
// ## Quick Start
//
// ```dart
// import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';
//
// final client = T1YClient(T1YClientConfig(
//   appId: 1001,
//   apiKey: '4fd7448cdc684431a62d8a0111dc69',
//   secretKey: '17b784e359c946ffa65eebbf9ce29',
// ));
//
// await client.init();
//
// // Database operations
// await client.db.collection('users').insertOne({
//   'name': 'Alice',
//   'age': 25,
//   'createdAt': timeNow.now(),
// });
//
// final result = await client.db.collection('users').findOne({'name': 'Alice'});
// print(result.data.result);
// ```
// Main client classes
export 'src/client/t1y_client.dart';
export 'src/client/t1y_collection.dart';

// Special type helpers
export 'src/special_types/object_id.dart';
export 'src/special_types/date_types.dart';
export 'src/special_types/numeric_types.dart';
export 'src/special_types/structured_types.dart';
export 'src/special_types/null_types.dart';
export 'src/special_types/time_helpers.dart';

// Cryptographic utilities
export 'src/crypto/sha256.dart';
export 'src/crypto/hmac.dart';
export 'src/crypto/aes.dart';
export 'src/crypto/sign.dart';

// Utility functions
export 'src/utils/constants.dart';
export 'src/utils/convert.dart';
export 'src/utils/errors.dart';
export 'src/utils/time_utils.dart';
export 'src/utils/url_utils.dart';
export 'src/utils/validators.dart';

// Core types
export 'src/types/client_types.dart';
export 'src/types/api_types.dart';
