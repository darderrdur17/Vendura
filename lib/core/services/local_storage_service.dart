import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  // Database name and version
  static const String _databaseName = 'vendura_pos.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableItems = 'items';
  static const String tableOrders = 'orders';
  static const String tableReceipts = 'receipts';
  static const String tablePayments = 'payments';
  static const String tablePendingSync = 'pending_sync';

  // Initialize the service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  // Initialize database
  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Items table
    await db.execute('''
      CREATE TABLE $tableItems (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        image_url TEXT,
        is_available INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE $tableOrders (
        id TEXT PRIMARY KEY,
        items TEXT NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Receipts table
    await db.execute('''
      CREATE TABLE $tableReceipts (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        receipt_number TEXT NOT NULL,
        items TEXT NOT NULL,
        total_amount REAL NOT NULL,
        tax_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE $tablePayments (
        id TEXT PRIMARY KEY,
        receipt_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Pending sync table
    await db.execute('''
      CREATE TABLE $tablePendingSync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        collection_name TEXT NOT NULL,
        document_id TEXT,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Upgrade database
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // SharedPreferences methods
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Database methods for Items
  static Future<void> insertItem(Map<String, dynamic> item) async {
    await _database?.insert(
      tableItems,
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableItems,
      orderBy: 'category, name',
    );
    return result ?? [];
  }

  static Future<List<Map<String, dynamic>>> getItemsByCategory(String category) async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableItems,
      where: 'category = ? AND is_available = 1',
      whereArgs: [category],
      orderBy: 'name',
    );
    return result ?? [];
  }

  static Future<void> updateItem(String id, Map<String, dynamic> item) async {
    await _database?.update(
      tableItems,
      item,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteItem(String id) async {
    await _database?.delete(
      tableItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Database methods for Orders
  static Future<void> insertOrder(Map<String, dynamic> order) async {
    await _database?.insert(
      tableOrders,
      order,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableOrders,
      orderBy: 'created_at DESC',
    );
    return result ?? [];
  }

  static Future<Map<String, dynamic>?> getOrder(String id) async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result?.isNotEmpty == true ? result!.first : null;
  }

  static Future<void> updateOrder(String id, Map<String, dynamic> order) async {
    await _database?.update(
      tableOrders,
      order,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteOrder(String id) async {
    await _database?.delete(
      tableOrders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Database methods for Receipts
  static Future<void> insertReceipt(Map<String, dynamic> receipt) async {
    await _database?.insert(
      tableReceipts,
      receipt,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getReceipts() async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableReceipts,
      orderBy: 'created_at DESC',
    );
    return result ?? [];
  }

  static Future<List<Map<String, dynamic>>> getReceiptsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startDateStr = startDate.toIso8601String();
    final endDateStr = endDate.toIso8601String();
    
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableReceipts,
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [startDateStr, endDateStr],
      orderBy: 'created_at DESC',
    );
    return result ?? [];
  }

  static Future<Map<String, dynamic>?> getReceipt(String id) async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tableReceipts,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result?.isNotEmpty == true ? result!.first : null;
  }

  static Future<void> updateReceipt(String id, Map<String, dynamic> receipt) async {
    await _database?.update(
      tableReceipts,
      receipt,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Database methods for Payments
  static Future<void> insertPayment(Map<String, dynamic> payment) async {
    await _database?.insert(
      tablePayments,
      payment,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tablePayments,
      orderBy: 'created_at DESC',
    );
    return result ?? [];
  }

  // Database methods for Pending Sync
  static Future<void> addPendingSync(Map<String, dynamic> syncOperation) async {
    await _database?.insert(
      tablePendingSync,
      syncOperation,
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final List<Map<String, dynamic>>? result = await _database?.query(
      tablePendingSync,
      orderBy: 'created_at ASC',
    );
    return result ?? [];
  }

  static Future<void> removePendingSyncOperation(int id) async {
    await _database?.delete(
      tablePendingSync,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Utility methods
  static Future<void> clearAllData() async {
    await _database?.delete(tableItems);
    await _database?.delete(tableOrders);
    await _database?.delete(tableReceipts);
    await _database?.delete(tablePayments);
    await _database?.delete(tablePendingSync);
  }

  static Future<void> close() async {
    await _database?.close();
  }

  // Helper methods for data conversion
  static String encodeJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, dynamic> decodeJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
} 