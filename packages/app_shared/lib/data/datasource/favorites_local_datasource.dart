/// Local persistence for favorite Pokémon ids.
///
/// Storage is platform-specific, so subclasses provide only the three
/// primitives below — `SharedPrefsFavoritesDataSource` (shared_preferences)
/// in apps/mobile, `BrowserFavoritesDataSource` (localStorage) in apps/web.
/// The add/remove/toggle logic is written once, here.
abstract class FavoritesLocalDataSource {
  /// Get all favorite Pokemon IDs
  Future<Set<int>> getFavoriteIds();

  /// Persist the full set of favorite IDs
  Future<void> saveFavoriteIds(Set<int> ids);

  /// Clear all favorites
  Future<void> clearAll();

  /// Add a Pokemon to favorites
  Future<void> addFavorite(int id) async {
    final ids = await getFavoriteIds();
    ids.add(id);
    await saveFavoriteIds(ids);
  }

  /// Remove a Pokemon from favorites
  Future<void> removeFavorite(int id) async {
    final ids = await getFavoriteIds();
    ids.remove(id);
    await saveFavoriteIds(ids);
  }

  /// Check if a Pokemon is favorited
  Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(int id) async {
    final isFav = await isFavorite(id);
    if (isFav) {
      await removeFavorite(id);
      return false;
    } else {
      await addFavorite(id);
      return true;
    }
  }
}
