import 'package:app_shared/data/datasource/favorites_local_datasource.dart';
import 'package:universal_web/web.dart' as web;

/// localStorage-backed favorites — web twin of mobile's
/// `SharedPrefsFavoritesDataSource` (same storage key, ids comma-joined).
class BrowserFavoritesDataSource extends FavoritesLocalDataSource {
  BrowserFavoritesDataSource({web.Storage? storage})
    : _storage = storage ?? web.window.localStorage;

  static const _key = 'favorite_pokemon_ids';
  final web.Storage _storage;

  @override
  Future<Set<int>> getFavoriteIds() async {
    final raw = _storage.getItem(_key);
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').map(int.tryParse).whereType<int>().toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<int> ids) async {
    _storage.setItem(_key, ids.join(','));
  }

  @override
  Future<void> clearAll() async => _storage.removeItem(_key);
}
