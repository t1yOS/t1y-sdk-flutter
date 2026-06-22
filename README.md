# t1yOS SDK for Flutter/Dart

[中文文档](./README.zh-CN.md)

[t1yOS](https://www.t1y.net) Serverless Platform Flutter/Dart SDK — cloud database, metadata, and cloud functions client.

## Installation

Add `t1y_sdk_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  t1y_sdk_flutter: ^0.0.2
```

Or install via command line:

```bash
flutter pub add t1y_sdk_flutter
```

## Quick Start

```dart
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

// 1. Create client
final client = T1YClient(T1YClientConfig(
  appId: 1001, // Required: your application ID (>= 1001)
  apiKey: '4fd7448cdc684431a62d8a0111dc69', // Required: 32-character API Key
  secretKey: '17b784e359c946ffa65eebbf9ce29', // Required: 32-character Secret Key
  // Optional with defaults:
  // baseUrl: 'https://myapp.t1y.net',
  // version: 0,
  // isSafeMode: false,
  // timeFormat: 'YYYY-MM-DD HH:mm:ss',
  // offset: 0,
));

// 2. Initialize (syncs time offset and safe mode with server)
await client.init();

// 3. Use the database!
await client.db.collection('users').insertOne({
  'name': 'Alice',
  'age': 25,
  'active': true,
  'customTimeAt': timeNow.now(),
});
```

## Database Operations

### Single Document

```dart
final db = client.db.collection('users');

// Insert one
final insertResult = await db.insertOne({'name': 'Alice', 'age': 25});
print(insertResult.data.objectId); // '507f1f77bcf86cd799439011'

// Find by ObjectID
final findResult = await db.findById('507f1f77bcf86cd799439011');
print(findResult.data.result); // { _id: '507f1f77...', name: 'Alice', ... }

// Update by ObjectID
await db.updateById('507f1f77bcf86cd799439011', {r'$set': {'age': 26}});

// Delete by ObjectID
await db.deleteById('507f1f77bcf86cd799439011');
```

### Filter-based Operations

```dart
// Find one by filter
final result = await db.findOne({'name': 'Alice'});

// Update one by filter
await db.updateOne(
  {'name': 'Alice'}, // filter
  {r'$set': {'age': 27}}, // update body
);

// Delete one by filter
await db.deleteOne({'name': 'Alice'});
```

### Bulk Operations

```dart
// Insert many
final result = await db.insertMany([
  {'name': 'Alice', 'age': 25},
  {'name': 'Bob', 'age': 30},
]);
print(result.data.insertedCount); // 2

// Delete many
await db.deleteMany({'age': {r'$lt': 18}});

// Update many
await db.updateMany(
  {'status': 'inactive'},
  {r'$set': {'status': 'archived'}},
);
```

### Advanced Queries

```dart
// Paginated find
final result = await db.find(
  page: 1,
  size: 20,
  sort: {'createdAt': -1}, // newest first
  filter: {'age': {r'$gte': 18}},
);
print(result.data.results); // Array of documents
print(result.data.pagination); // { totalItems: 42, totalPages: 3 }

// Aggregation pipeline
final aggResult = await db.aggregate([
  {r'$match': {'status': 'completed'}},
  {r'$group': {'_id': r'$category', 'total': {r'$sum': r'$amount'}}},
  {r'$sort': {'total': -1}},
]);

// Count
final countResult = await client.db.collection('users').count(
  filter: {'status': 'active'},
);
print(countResult.data['count']);

// Distinct values
final distinctResult = await client.db.collection('users').distinct('city');
// With filter
final filtered = await client.db
    .collection('users')
    .distinct('city', filter: {'country': 'China'});
```

### Schema Management

```dart
// Get all collections
final collections = await client.db.getCollections();
print(collections.data['results']); // ['users', 'orders', 'products']

// Create a collection
await client.db.collection('posts').create();

// Clear a collection
final clearResult = await client.db.collection('posts').clear();
print(clearResult.data['deletedCount']);

// Drop a collection
await client.db.collection('posts').drop();
```

## Special Types

The SDK provides helper functions that produce server-recognized type markers:

```dart
await db.insertOne({
  // ObjectID reference
  'userId': objectIdMarker('507f1f77bcf86cd799439011'),

  // Date types
  'birthday': dateMarker('2000-01-01T00:00:00Z'),
  'eventTime': dateTimeMarker('2024-06-15T14:30:00Z'),
  'loginAt': timestampMarker(1705312200),

  // Numeric types
  'active': booleanMarker(true),
  'quantity': integerMarker(42),
  'bigNumber': bigintMarker(9007199254740991),
  'rating': floatMarker(4.5),
  'preciseValue': doubleMarker(3.141592653589793),

  // Structured types
  'tags': arrayMarker(['dart', 'flutter']),
  'metadata': mapMarker({'theme': 'dark', 'lang': 'en'}),
  'history': mapArrayMarker([{'action': 'login'}, {'action': 'logout'}]),

  // Null values
  'deletedAt': nullValue, // server converts to nil
  'middleName': noneValue, // server converts to nil

  // Server-time helpers
  'customTimeAt': timeNow.now(), // server's time.Now()
  'unixCreatedAt': timeNow.nowUnix(), // server's time.Now().Unix()
});
```

## Metadata

```dart
// Get all metadata
final meta = await client.getMeta();
print(meta.data); // { version: 1, collections: [...], ... }

// Get specific field
final versionData = await client.getMeta('version');
print(versionData.data); // { result: 1 }

// Check for updates
final hasUpdate = await client.checkUpdate();
```

## Cloud Functions

```dart
// Call a .jsc cloud function
final result = await client.callFunc('hello', {'name': 'World'});

// With safe mode enabled for this specific call
final safeResult = await client.callFunc('secureFunc', params, true);
```

## Security

### Authentication Headers

Every request includes:

- `X-T1Y-Application-ID` — Your application ID
- `X-T1Y-API-Key` — Your 32-character API key
- `X-T1Y-Safe-Timestamp` — Unix timestamp (UTC + time offset from init)
- `X-T1Y-Safe-Sign` — HMAC-SHA256 signature (64 hex chars)

### Signature Algorithm

```
message = METHOD + "\n" + URL_PATH + "\n" + SHA256(body) + "\n" + appId + "\n" + timestamp
signature = HMAC-SHA256(secretKey, message)
```

### Safe Mode (AES-256-GCM)

When safe mode is enabled (via `isSafeMode: true` or auto-detected from init), request bodies are encrypted with AES-256-GCM using your SecretKey, and server responses are decrypted automatically.

## API Reference

### T1YClient

| Method                                        | Description                                        |
| --------------------------------------------- | -------------------------------------------------- |
| `T1YClient(config)`                           | Create client (validates appId, apiKey, secretKey) |
| `init()`                                      | Sync time offset and safe mode with server         |
| `db.collection(name)`                         | Get a collection instance (chainable)              |
| `db.toObjectID(id)`                           | Create ObjectID marker string                      |
| `db.getCollections()`                         | List all collections                               |
| `getMeta(field?)`                             | Get application metadata                           |
| `checkUpdate()`                               | Check if newer version exists                      |
| `callFunc(name, params?, safeMode?)`          | Call a cloud function                              |
| `request(method, path, params?, encryption?)` | Raw authenticated request                          |

### T1YCollection

| Method                           | HTTP   | Endpoint                            |
| -------------------------------- | ------ | ----------------------------------- |
| `insertOne(data)`                | POST   | `/v5/classes/:name`                 |
| `deleteById(objectId)`           | DELETE | `/v5/classes/:name/:objectId`       |
| `updateById(objectId, data)`     | PUT    | `/v5/classes/:name/:objectId`       |
| `findById(objectId)`             | GET    | `/v5/classes/:name/:objectId`       |
| `deleteOne(filter)`              | DELETE | `/v5/classes/:name/one`             |
| `updateOne(filter, body)`        | PUT    | `/v5/classes/:name/one`             |
| `findOne(filter)`                | POST   | `/v5/classes/:name/one`             |
| `insertMany(dataList)`           | POST   | `/v5/classes/:name/many`            |
| `deleteMany(filter)`             | DELETE | `/v5/classes/:name/many`            |
| `updateMany(filter, body)`       | PUT    | `/v5/classes/:name/many`            |
| `find(page, size, sort, filter)` | POST   | `/v5/classes/:name/find`            |
| `aggregate(pipeline)`            | POST   | `/v5/classes/:name/aggregate`       |
| `count(filter?)`                 | POST   | `/v5/classes/:name/count`           |
| `distinct(fieldName, filter?)`   | POST   | `/v5/classes/:name/distinct/:field` |
| `create()`                       | POST   | `/v5/schemas/:name`                 |
| `clear()`                        | PUT    | `/v5/schemas/:name`                 |
| `drop()`                         | DELETE | `/v5/schemas/:name`                 |

T1YClient `db` object also provides:

| Method                | HTTP | Endpoint      |
| --------------------- | ---- | ------------- |
| `db.getCollections()` | GET  | `/v5/schemas` |

## License

MIT

Copyright (c) 2026 华易云联（杭州）网络科技有限责任公司
