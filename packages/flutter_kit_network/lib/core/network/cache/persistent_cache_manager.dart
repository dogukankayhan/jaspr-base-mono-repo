import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Persistent cache manager using SQLite
///
/// Features:
/// - SQLite-based persistent storage
/// - TTL (Time To Live) support
/// - Automatic expiration cleanup
/// - Size-based eviction (LRU)
/// - Cache statistics
class PersistentCacheManager {
  static const String _tableName = 'http_cache';
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB

  Database? _database;

  /// Initialize database
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'http_cache.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            headers TEXT,
            status_code INTEGER,
            created_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL,
            size INTEGER NOT NULL,
            access_count INTEGER DEFAULT 0,
            last_accessed INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_expires_at ON $_tableName(expires_at)
        ''');

        await db.execute('''
          CREATE INDEX idx_last_accessed ON $_tableName(last_accessed)
        ''');
      },
    );

    // Clean expired entries on init
    await _cleanupExpired();
  }

  /// Get cached entry
  Future<CacheEntry?> get(String key) async {
    if (_database == null) throw StateError('Database not initialized');

    final results = await _database!.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;

    final map = results.first;
    final expiresAt = map['expires_at'] as int;

    // Check expiration
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await delete(key);
      return null;
    }

    // Update access stats
    await _database!.update(
      _tableName,
      {
        'access_count': (map['access_count'] as int) + 1,
        'last_accessed': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'key = ?',
      whereArgs: [key],
    );

    return CacheEntry.fromMap(map);
  }

  /// Put entry in cache
  Future<void> put(
    String key,
    String data, {
    Map<String, String>? headers,
    int? statusCode,
    Duration? ttl,
  }) async {
    if (_database == null) throw StateError('Database not initialized');

    final now = DateTime.now().millisecondsSinceEpoch;
    final defaultTtl = ttl ?? const Duration(hours: 1);
    final expiresAt = now + defaultTtl.inMilliseconds;
    final size = utf8.encode(data).length;

    // Check cache size and evict if needed
    await _evictIfNeeded(size);

    await _database!.insert(_tableName, {
      'key': key,
      'data': data,
      'headers': headers != null ? jsonEncode(headers) : null,
      'status_code': statusCode,
      'created_at': now,
      'expires_at': expiresAt,
      'size': size,
      'access_count': 0,
      'last_accessed': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Delete cache entry
  Future<void> delete(String key) async {
    if (_database == null) throw StateError('Database not initialized');

    await _database!.delete(_tableName, where: 'key = ?', whereArgs: [key]);
  }

  /// Clear all cache
  Future<void> clear() async {
    if (_database == null) throw StateError('Database not initialized');

    await _database!.delete(_tableName);
  }

  /// Clean expired entries
  Future<void> _cleanupExpired() async {
    if (_database == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    await _database!.delete(
      _tableName,
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }

  /// Evict old entries if cache is full (LRU)
  Future<void> _evictIfNeeded(int newEntrySize) async {
    if (_database == null) return;

    final stats = await getStats();
    final totalSize = stats.totalSize + newEntrySize;

    if (totalSize <= _maxCacheSize) return;

    // Calculate how much to evict
    final toEvict = totalSize - _maxCacheSize;
    int evicted = 0;

    // Get entries ordered by last access (LRU)
    final entries = await _database!.query(
      _tableName,
      orderBy: 'last_accessed ASC',
    );

    for (final entry in entries) {
      if (evicted >= toEvict) break;

      final key = entry['key'] as String;
      final size = entry['size'] as int;

      await delete(key);
      evicted += size;
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    if (_database == null) throw StateError('Database not initialized');

    final result = await _database!.rawQuery('''
      SELECT 
        COUNT(*) as count,
        SUM(size) as total_size,
        AVG(access_count) as avg_access_count
      FROM $_tableName
    ''');

    final map = result.first;

    return CacheStats(
      entryCount: map['count'] as int,
      totalSize: (map['total_size'] as int?) ?? 0,
      avgAccessCount: (map['avg_access_count'] as double?) ?? 0.0,
      maxCacheSize: _maxCacheSize,
    );
  }

  /// Close database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

/// Cache entry model
class CacheEntry {
  final String key;
  final String data;
  final Map<String, String>? headers;
  final int? statusCode;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int size;
  final int accessCount;
  final DateTime lastAccessed;

  CacheEntry({
    required this.key,
    required this.data,
    this.headers,
    this.statusCode,
    required this.createdAt,
    required this.expiresAt,
    required this.size,
    required this.accessCount,
    required this.lastAccessed,
  });

  factory CacheEntry.fromMap(Map<String, dynamic> map) {
    return CacheEntry(
      key: map['key'] as String,
      data: map['data'] as String,
      headers: map['headers'] != null
          ? Map<String, String>.from(jsonDecode(map['headers'] as String))
          : null,
      statusCode: map['status_code'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expires_at'] as int),
      size: map['size'] as int,
      accessCount: map['access_count'] as int,
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(
        map['last_accessed'] as int,
      ),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get age => DateTime.now().difference(createdAt);

  Duration get timeToExpire => expiresAt.difference(DateTime.now());
}

/// Cache statistics
class CacheStats {
  final int entryCount;
  final int totalSize;
  final double avgAccessCount;
  final int maxCacheSize;

  CacheStats({
    required this.entryCount,
    required this.totalSize,
    required this.avgAccessCount,
    required this.maxCacheSize,
  });

  double get usagePercentage => (totalSize / maxCacheSize) * 100;

  String get totalSizeFormatted {
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(2)} KB';
    }
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  String toString() =>
      '''
CacheStats(
  entries: $entryCount,
  size: $totalSizeFormatted,
  usage: ${usagePercentage.toStringAsFixed(2)}%,
  avgAccess: ${avgAccessCount.toStringAsFixed(2)}
)''';
}
