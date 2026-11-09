abstract class LocalDataSource<T> {
  /// Get cached data by key
  Future<T?> get(String key);

  /// Save data to cache
  Future<void> save(String key, T data);

  /// Delete cached data by key
  Future<void> delete(String key);

  /// Clear all cached data
  Future<void> clear();

  /// Check if data exists in cache
  Future<bool> exists(String key);

  /// Get all cached data
  Future<Map<String, T>> getAll();

  /// Check if cached data is expired
  Future<bool> isExpired(String key);
}
