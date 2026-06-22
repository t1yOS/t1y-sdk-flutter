# t1yOS SDK for Flutter/Dart

[English](./README.md)

[t1yOS](https://www.t1y.net) Serverless 平台 Flutter/Dart SDK — 云数据库、元数据和云函数客户端。

## 安装

在 `pubspec.yaml` 中添加 `t1y_sdk_flutter`：

```yaml
dependencies:
  t1y_sdk_flutter: ^0.0.2
```

或通过命令行安装：

```bash
flutter pub add t1y_sdk_flutter
```

## 快速开始

```dart
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

// 1. 创建客户端
final client = T1YClient(T1YClientConfig(
  appId: 1001, // 必填：应用 ID（>= 1001）
  apiKey: '4fd7448cdc684431a62d8a0111dc69', // 必填：32 位 API Key
  secretKey: '17b784e359c946ffa65eebbf9ce29', // 必填：32 位 Secret Key
  // 以下参数可选（均有默认值）：
  // baseUrl: 'https://myapp.t1y.net',
  // version: 0,
  // isSafeMode: false,
  // timeFormat: 'YYYY-MM-DD HH:mm:ss',
  // offset: 0,
));

// 2. 初始化（与服务器同步时间偏移和安全模式）
await client.init();

// 3. 开始使用数据库！
await client.db.collection('users').insertOne({
  'name': '张三',
  'age': 25,
  'active': true,
  'customTimeAt': timeNow.now(),
});
```

## 数据库操作

### 单条操作

```dart
final db = client.db.collection('users');

// 插入一条
final insertResult = await db.insertOne({'name': '张三', 'age': 25});
print(insertResult.data.objectId); // '507f1f77bcf86cd799439011'

// 通过 ObjectID 查询
final findResult = await db.findById('507f1f77bcf86cd799439011');
print(findResult.data.result); // { _id: '507f1f77...', name: '张三', ... }

// 通过 ObjectID 更新
await db.updateById('507f1f77bcf86cd799439011', {r'$set': {'age': 26}});

// 通过 ObjectID 删除
await db.deleteById('507f1f77bcf86cd799439011');
```

### 条件操作

```dart
// 条件查询一条
final result = await db.findOne({'name': '张三'});

// 条件更新一条
await db.updateOne(
  {'name': '张三'}, // 查询条件
  {r'$set': {'age': 27}}, // 更新内容
);

// 条件删除一条
await db.deleteOne({'name': '张三'});
```

### 批量操作

```dart
// 插入多条
final result = await db.insertMany([
  {'name': '张三', 'age': 25},
  {'name': '李四', 'age': 30},
]);
print(result.data.insertedCount); // 2

// 删除多条
await db.deleteMany({'age': {r'$lt': 18}});

// 更新多条
await db.updateMany(
  {'status': 'inactive'},
  {r'$set': {'status': 'archived'}},
);
```

### 高级查询

```dart
// 分页查询
final result = await db.find(
  page: 1,
  size: 20,
  sort: {'createdAt': -1}, // 按创建时间倒序
  filter: {'age': {r'$gte': 18}},
);
print(result.data.results); // 文档数组
print(result.data.pagination); // { totalItems: 42, totalPages: 3 }

// 聚合查询
final aggResult = await db.aggregate([
  {r'$match': {'status': 'completed'}},
  {r'$group': {'_id': r'$category', 'total': {r'$sum': r'$amount'}}},
  {r'$sort': {'total': -1}},
]);

// 计数
final countResult = await client.db.collection('users').count(
  filter: {'status': 'active'},
);
print(countResult.data['count']);

// 去重查询
final distinctResult = await client.db.collection('users').distinct('city');
// 带条件过滤
final filtered = await client.db
    .collection('users')
    .distinct('city', filter: {'country': 'China'});
```

### 表管理

```dart
// 获取所有表
final collections = await client.db.getCollections();
print(collections.data['results']); // ['users', 'orders', 'products']

// 创建表
await client.db.collection('posts').create();

// 清空表
final clearResult = await client.db.collection('posts').clear();
print(clearResult.data['deletedCount']);

// 删除表
await client.db.collection('posts').drop();
```

## 特殊类型

SDK 提供了一系列辅助函数，用于生成服务端可识别的类型标记：

```dart
await db.insertOne({
  // ObjectID 引用
  'userId': objectIdMarker('507f1f77bcf86cd799439011'),

  // 日期类型
  'birthday': dateMarker('2000-01-01T00:00:00Z'),
  'eventTime': dateTimeMarker('2024-06-15T14:30:00Z'),
  'loginAt': timestampMarker(1705312200),

  // 数值类型
  'active': booleanMarker(true),
  'quantity': integerMarker(42),
  'bigNumber': bigintMarker(9007199254740991),
  'rating': floatMarker(4.5),
  'preciseValue': doubleMarker(3.141592653589793),

  // 结构化类型
  'tags': arrayMarker(['dart', 'flutter']),
  'metadata': mapMarker({'theme': 'dark', 'lang': 'zh'}),
  'history': mapArrayMarker([{'action': 'login'}, {'action': 'logout'}]),

  // 空值
  'deletedAt': nullValue, // 服务端转为 nil
  'middleName': noneValue, // 服务端转为 nil

  // 服务端时间辅助
  'customTimeAt': timeNow.now(), // 服务端的 time.Now()
  'unixCreatedAt': timeNow.nowUnix(), // 服务端的 time.Now().Unix()
});
```

## 元数据

```dart
// 获取全部元数据
final meta = await client.getMeta();
print(meta.data); // { version: 1, collections: [...], ... }

// 获取指定字段
final versionData = await client.getMeta('version');
print(versionData.data); // { result: 1 }

// 检查更新
final hasUpdate = await client.checkUpdate();
```

## 云函数

```dart
// 调用 .jsc 云函数
final result = await client.callFunc('hello', {'name': 'World'});

// 为此调用单独启用安全模式
final safeResult = await client.callFunc('secureFunc', params, true);
```

## 安全机制

### 认证请求头

每个请求都会携带以下请求头：

- `X-T1Y-Application-ID` — 应用 ID
- `X-T1Y-API-Key` — 32 位 API Key
- `X-T1Y-Safe-Timestamp` — Unix 时间戳（UTC + 初始化时获取的时间偏移）
- `X-T1Y-Safe-Sign` — HMAC-SHA256 签名（64 位十六进制）

### 签名算法

```
message = METHOD + "\n" + URL_PATH + "\n" + SHA256(body) + "\n" + appId + "\n" + timestamp
signature = HMAC-SHA256(secretKey, message)
```

### 安全模式（AES-256-GCM）

当启用安全模式时（通过 `isSafeMode: true` 或初始化时自动检测），请求体将使用 AES-256-GCM 加密，密钥为应用的 SecretKey，服务端响应也会自动解密。

## API 参考

### T1YClient

| 方法                                          | 说明                                        |
| --------------------------------------------- | ------------------------------------------- |
| `T1YClient(config)`                           | 创建客户端（校验 appId、apiKey、secretKey） |
| `init()`                                      | 与服务端同步时间偏移和安全模式              |
| `db.collection(name)`                         | 获取集合操作实例（链式调用）                |
| `db.toObjectID(id)`                           | 创建 ObjectID 标记字符串                    |
| `db.getCollections()`                         | 获取所有表                                  |
| `getMeta(field?)`                             | 获取应用元数据                              |
| `checkUpdate()`                               | 检查是否存在新版本                          |
| `callFunc(name, params?, safeMode?)`          | 调用云函数                                  |
| `request(method, path, params?, encryption?)` | 原始认证请求                                |

### T1YCollection

| 方法                             | HTTP   | 端点                                |
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

T1YClient `db` 对象还提供：

| 方法                  | HTTP | 端点          |
| --------------------- | ---- | ------------- |
| `db.getCollections()` | GET  | `/v5/schemas` |

## 开源协议

MIT

Copyright (c) 2026 华易云联（杭州）网络科技有限责任公司
