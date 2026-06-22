## 0.0.2

- **Added**: `T1YLogger` — lightweight static logger with four levels (`debug`, `info`, `warning`, `error`), custom handler support, and per-level filtering. Replaces raw `print()` calls in the SDK.
- **Added**: Comprehensive `example/` directory with a Flutter demo app showcasing all SDK features (initialization, single/bulk CRUD, pagination, aggregation, cloud functions, metadata, special types, and logger configuration).
- **Added**: Modular unit test suite — 281 tests across 16 files covering AES-GCM round-trip, HMAC-SHA256 (including pure-Dart fallback cross-validation), SHA-256 known-value verification, request signature generation, HTTP response handling (success/error/safe-mode/timestamp branches), `handleFetchError`, all API type `fromJson` factories, `convertDateTypes` recursive conversion, timestamp formatting, URL utilities, validator edge cases, logger handler/level behaviour, all special-type markers, client construction, and collection input validation.
- **Fixed**: `encryptAESGCM` and `decryptAESGCM` — properly capture `doFinal` return values for correct output buffer slicing, fixing AES-GCM round-trip errors.
- **Fixed**: `T1YClient.verifyHmacSHA256` — resolved infinite-recursion bug caused by the class method shadowing the imported top-level function.

## 0.0.1

- Initial release of t1yOS SDK for Flutter/Dart.
- T1YClient: Main client class with initialization, metadata, cloud functions, and authenticated HTTP requests.
- T1YCollection: Chainable database collection class with 17 CRUD and schema management methods.
- Cryptographic utilities: SHA-256, HMAC-SHA256, AES-256-GCM encryption/decryption, and request signing.
- Special type markers: ObjectID, Date, DateTime, Timestamp, Boolean, Integer, Bigint, Float, Double, Array, Map, MapArray, null types, and server-time helpers (timeNow).
- Safe mode support: AES-256-GCM encryption for request/response bodies.
- Comprehensive input validation and error handling (T1YError, ValidationError).
- Timestamp formatting utilities (createdAt/updatedAt → local time).
- Bilingual documentation (English and Chinese README).
- Unit tests covering client, crypto, special types, utilities, validators, and error classes.
