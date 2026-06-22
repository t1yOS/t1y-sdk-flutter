// ignore_for_file: avoid_print
//
// t1y_sdk_flutter — Full Demo
//
// Demonstrates all major features of the t1yOS SDK.
//
// USAGE:
//   1. Replace APP_ID, API_KEY, SECRET_KEY below with real credentials.
//   2. Run with `flutter run`.
//
// Note: This example uses `print()` for demo purposes — in a real app you
// would configure `T1YLogger.setHandler()` to route logs to your system.

import 'package:flutter/material.dart';
import 'package:t1y_sdk_flutter/t1y_sdk_flutter.dart';

// =============================================================================
// Replace these with your real t1yOS credentials
// =============================================================================
const int kAppId = 1001;
const String kApiKey = 'your-32-character-api-key-here!!';
const String kSecretKey = 'your-32-character-secret-key-here';

void main() {
  runApp(const T1YExampleApp());
}

class T1YExampleApp extends StatelessWidget {
  const T1YExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 't1y_sdk_flutter Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  late final T1YClient _client;
  final List<String> _logs = [];
  bool _initialized = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------------------
    // 1. Configure the SDK logger
    // -------------------------------------------------------------------
    T1YLogger.setLevel(T1YLogLevel.debug);
    T1YLogger.setHandler((level, message, [error]) {
      final prefix = level.name.toUpperCase().padRight(7);
      _addLog('[$prefix] $message');
    });

    // -------------------------------------------------------------------
    // 2. Create the client
    // -------------------------------------------------------------------
    _client = T1YClient(T1YClientConfig(
      appId: kAppId,
      apiKey: kApiKey,
      secretKey: kSecretKey,
      // Optional overrides (defaults shown):
      // baseUrl: 'https://myapp.t1y.net',
      // version: 0,
      // isSafeMode: false,
      // timeFormat: 'YYYY-MM-DD HH:mm:ss',
      // offset: 0,
    ));

    _addLog('SDK client created');
  }

  void _addLog(String text) {
    setState(() => _logs.add('[${DateTime.now().toIso8601String()}] $text'));
  }

  // ==========================================================================
  // Actions
  // ==========================================================================

  Future<void> _init() async {
    setState(() => _loading = true);
    _addLog('Initializing...');
    try {
      await _client.init();
      _initialized = true;
      _addLog('Initialized ✓');
    } catch (e) {
      _addLog('Init failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runAllExamples() async {
    if (!_initialized) return;
    setState(() => _loading = true);

    try {
      final db = _client.db.collection('example_users');

      // -----------------------------------------------------------------
      // Schema: create the collection
      // -----------------------------------------------------------------
      _addLog('Creating collection...');
      await db.create();
      _addLog('Collection created ✓');

      // -----------------------------------------------------------------
      // Insert one document
      // -----------------------------------------------------------------
      final insert = await db.insertOne({
        'name': 'Alice',
        'age': 30,
        'email': 'alice@example.com',
        'tags': arrayMarker(['flutter', 'dart']),
        'createdAt': timeNow.now(),
      });
      _addLog('Inserted one — objectId: ${insert.data.objectId}');

      // -----------------------------------------------------------------
      // Insert many documents
      // -----------------------------------------------------------------
      final insertMany = await db.insertMany([
        {'name': 'Bob', 'age': 25, 'email': 'bob@example.com'},
        {'name': 'Charlie', 'age': 35, 'email': 'charlie@example.com'},
      ]);
      _addLog('Inserted many — count: ${insertMany.data.insertedCount}');

      // -----------------------------------------------------------------
      // Find one by filter
      // -----------------------------------------------------------------
      final found = await db.findOne({'name': 'Alice'});
      _addLog('findOne(name=Alice): ${found.data.result}');

      // -----------------------------------------------------------------
      // Paginated find
      // -----------------------------------------------------------------
      final page = await db.find(
        page: 1,
        size: 10,
        sort: {'createdAt': -1},
      );
      _addLog(
        'find page 1: ${page.data.results.length} results, '
        'total=${page.data.pagination.totalItems}',
      );

      // -----------------------------------------------------------------
      // Aggregation
      // -----------------------------------------------------------------
      final agg = await db.aggregate([
        {'\$group': {'_id': null, 'avgAge': {'\$avg': '\$age'}}},
      ]);
      _addLog('aggregate: ${agg.data.results}');

      // -----------------------------------------------------------------
      // Count
      // -----------------------------------------------------------------
      final count = await db.count(filter: {'age': {r'$gte': 25}});
      _addLog('count(age>=25): ${count.data}');

      // -----------------------------------------------------------------
      // Distinct
      // -----------------------------------------------------------------
      final distinct = await db.distinct('name');
      _addLog('distinct names: ${distinct.data}');

      // -----------------------------------------------------------------
      // Update one
      // -----------------------------------------------------------------
      final update = await db.updateOne(
        {'name': 'Alice'},
        {r'$set': {'age': 31}},
      );
      _addLog('updateOne — modified: ${update.data.modifiedCount}');

      // -----------------------------------------------------------------
      // Update many
      // -----------------------------------------------------------------
      final updateMany = await db.updateMany(
        {'name': {r'$in': ['Bob', 'Charlie']}},
        {r'$set': {'verified': booleanMarker(true)}},
      );
      _addLog('updateMany — modified: ${updateMany.data.modifiedCount}');

      // -----------------------------------------------------------------
      // Delete one
      // -----------------------------------------------------------------
      final del = await db.deleteOne({'name': 'Alice'});
      _addLog('deleteOne — deleted: ${del.data.deletedCount}');

      // -----------------------------------------------------------------
      // Delete many
      // -----------------------------------------------------------------
      final delMany = await db.deleteMany({});
      _addLog('deleteMany — deleted: ${delMany.data.deletedCount}');

      // -----------------------------------------------------------------
      // Metadata
      // -----------------------------------------------------------------
      _addLog('Fetching metadata...');
      final meta = await _client.getMeta();
      _addLog('getMeta: ${meta.data}');
      final hasUpdate = await _client.checkUpdate();
      _addLog('checkUpdate: $hasUpdate');

      // -----------------------------------------------------------------
      // Cloud function
      // -----------------------------------------------------------------
      _addLog('Calling cloud function...');
      final funcResult = await _client.callFunc('hello', {'name': 'World'});
      _addLog('callFunc: ${funcResult.data}');

      // -----------------------------------------------------------------
      // Get all collections
      // -----------------------------------------------------------------
      final colls = await _client.db.getCollections();
      _addLog('getCollections: ${colls.data}');

      // -----------------------------------------------------------------
      // Cleanup: clear & drop
      // -----------------------------------------------------------------
      await db.clear();
      _addLog('Collection cleared ✓');
      await db.drop();
      _addLog('Collection dropped ✓');

      _addLog('=== All examples completed ===');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // ==========================================================================
  // UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('t1y_sdk_flutter Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: _loading ? null : _init,
                  child: const Text('1. Init'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed:
                      (_loading || !_initialized) ? null : _runAllExamples,
                  child: const Text('2. Run All Examples'),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, i) => Text(
                  _logs[i],
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: _logs[i].contains('ERROR')
                        ? Colors.redAccent
                        : _logs[i].contains('✓')
                            ? Colors.greenAccent
                            : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
