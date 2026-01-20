import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/market_data.dart';
import '../models/trade_order.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database?> get database async {
    try {
      if (_database != null) return _database;
      _database = await _initDB('trading.db');
      return _database;
    } catch (e) {
      print('Database not available: $e');
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      // SQLite not supported on web platform
      throw Exception('SQLite not available on web platform: $e');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Market data table
    await db.execute('''
      CREATE TABLE market_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        price REAL NOT NULL,
        volume INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        change REAL,
        change_percent REAL,
        high REAL,
        low REAL,
        open REAL,
        close REAL
      )
    ''');

    // Trade orders table
    await db.execute('''
      CREATE TABLE trade_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        order_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        executed_at TEXT,
        order_id TEXT
      )
    ''');

    // Risk assessment history
    await db.execute('''
      CREATE TABLE risk_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        risk_score REAL NOT NULL,
        risk_level TEXT NOT NULL,
        factors TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_market_data_symbol ON market_data(symbol)');
    await db.execute('CREATE INDEX idx_market_data_timestamp ON market_data(timestamp)');
    await db.execute('CREATE INDEX idx_orders_status ON trade_orders(status)');
  }

  // Market Data Operations
  Future<int> insertMarketData(MarketData data) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert('market_data', data.toMap());
  }

  Future<List<MarketData>> getMarketData(String symbol, {int limit = 100}) async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query(
      'market_data',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => MarketData.fromMap(map)).toList();
  }

  Future<MarketData?> getLatestMarketData(String symbol) async {
    final db = await database;
    if (db == null) return null;
    final List<Map<String, dynamic>> maps = await db.query(
      'market_data',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MarketData.fromMap(maps.first);
  }

  Future<int> deleteOldMarketData(int daysToKeep) async {
    final db = await database;
    if (db == null) return 0;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await db.delete(
      'market_data',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Trade Order Operations
  Future<int> insertOrder(TradeOrder order) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert('trade_orders', order.toMap());
  }

  Future<List<TradeOrder>> getPendingOrders() async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query(
      'trade_orders',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => TradeOrder.fromMap(map)).toList();
  }

  Future<int> updateOrderStatus(int id, String status, {String? orderId}) async {
    final db = await database;
    if (db == null) return 0;
    final Map<String, dynamic> updates = {
      'status': status,
      if (orderId != null) 'order_id': orderId,
      if (status == 'executed') 'executed_at': DateTime.now().toIso8601String(),
    };
    return await db.update('trade_orders', updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TradeOrder>> getAllOrders({int limit = 50}) async {
    final db = await database;
    if (db == null) return [];
    final List<Map<String, dynamic>> maps = await db.query(
      'trade_orders',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => TradeOrder.fromMap(map)).toList();
  }

  // Risk History Operations
  Future<int> insertRiskHistory(String symbol, double riskScore, String riskLevel, Map<String, dynamic> factors) async {
    final db = await database;
    if (db == null) return 0;
    return await db.insert('risk_history', {
      'symbol': symbol,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'factors': factors.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRiskHistory(String symbol, {int limit = 100}) async {
    final db = await database;
    if (db == null) return [];
    return await db.query(
      'risk_history',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
    _database = null;
  }
}

