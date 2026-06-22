# t1y_sdk_flutter Example

This example demonstrates the full capabilities of the t1yOS Flutter/Dart SDK.

## Running the Example

1. Replace the `appId`, `apiKey`, and `secretKey` placeholders in `lib/main.dart` with your actual t1yOS credentials.
2. Run `flutter pub get` in this directory.
3. Launch with `flutter run`.

## What's Demonstrated

| Feature | Description |
|---------|-------------|
| Client initialization | Creating a `T1YClient` with configuration and calling `init()` |
| Logger configuration | Custom log handler and log level filtering |
| Single-document CRUD | `insertOne`, `findById`, `updateById`, `deleteById` |
| Filter-based operations | `findOne`, `updateOne`, `deleteOne` with query filters |
| Bulk operations | `insertMany`, `updateMany`, `deleteMany` |
| Paginated queries | `find()` with page, size, sort, and filter |
| Aggregation pipeline | `aggregate()` with MongoDB-style pipeline stages |
| Count & distinct | `count()` and `distinct()` queries |
| Schema management | `create()`, `clear()`, `drop()`, `getCollections()` |
| Special types | ObjectID, Date, Timestamp, Boolean, Integer, Bigint, Float, Double, Array, Map, MapArray, null markers, and server-time helpers |
| Metadata | `getMeta()` and `checkUpdate()` |
| Cloud functions | `callFunc()` with optional safe-mode |
