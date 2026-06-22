## 0.0.1

* Initial release of t1yOS SDK for Flutter/Dart.
* T1YClient: Main client class with initialization, metadata, cloud functions, and authenticated HTTP requests.
* T1YCollection: Chainable database collection class with 17 CRUD and schema management methods.
* Cryptographic utilities: SHA-256, HMAC-SHA256, AES-256-GCM encryption/decryption, and request signing.
* Special type markers: ObjectID, Date, DateTime, Timestamp, Boolean, Integer, Bigint, Float, Double, Array, Map, MapArray, null types, and server-time helpers (timeNow).
* Safe mode support: AES-256-GCM encryption for request/response bodies.
* Comprehensive input validation and error handling (T1YError, ValidationError).
* Timestamp formatting utilities (createdAt/updatedAt → local time).
* Bilingual documentation (English and Chinese README).
* Unit tests covering client, crypto, special types, utilities, validators, and error classes.
