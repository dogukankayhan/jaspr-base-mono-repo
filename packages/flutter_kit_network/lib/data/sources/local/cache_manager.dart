import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_data_source.dart';

class CacheManager implements LocalDataSource<Map<String, dynamic>> {
  final SharedPreferences _prefs;
  static const String _expiryPrefix = '_expiry_';

  CacheManager(this._prefs);

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    // Check if expired
    if (await isExpired(key)) {
      await delete(key);
      return null;
    }

    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // If decode fails, remove corrupted data
      await delete(key);
      return null;
    }
  }

  @override
  Future<void> save(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    final jsonString = jsonEncode(data);
    await _prefs.setString(key, jsonString);

    // Set expiry time if TTL provided
    if (ttl != null) {
      final expiryTime = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _prefs.setInt('$_expiryPrefix$key', expiryTime);
    }
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
    await _prefs.remove('$_expiryPrefix$key');
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<bool> exists(String key) async {
    return _prefs.containsKey(key) && !(await isExpired(key));
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final keys = _prefs.getKeys().where(
      (key) => !key.startsWith(_expiryPrefix),
    );
    final result = <String, Map<String, dynamic>>{};

    for (final key in keys) {
      final data = await get(key);
      if (data != null) {
        result[key] = data;
      }
    }

    return result;
  }

  @override
  Future<bool> isExpired(String key) async {
    final expiryKey = '$_expiryPrefix$key';
    final expiryTime = _prefs.getInt(expiryKey);

    if (expiryTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiryTime;
  }

  /// Get cache size in bytes (approximate)
  Future<int> getCacheSize() async {
    int size = 0;
    for (final key in _prefs.getKeys()) {
      final value = _prefs.get(key);
      if (value is String) {
        size += value.length;
      }
    }
    return size;
  }

  /// Remove expired items
  Future<void> clearExpired() async {
    final keys = _prefs.getKeys().where(
      (key) => !key.startsWith(_expiryPrefix),
    );
    for (final key in keys) {
      if (await isExpired(key)) {
        await delete(key);
      }
    }
  }
}
