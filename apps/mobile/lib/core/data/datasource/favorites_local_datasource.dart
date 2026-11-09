import 'package:app_shared/data/datasource/favorites_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences-backed [FavoritesLocalDataSource] for the Flutter app.
class SharedPrefsFavoritesDataSource extends FavoritesLocalDataSource {
  final SharedPreferences _prefs;
  static const _key = 'favorite_pokemon_ids';

  SharedPrefsFavoritesDataSource(this._prefs);

  @override
  Future<Set<int>> getFavoriteIds() async {
    final stringIds = _prefs.getStringList(_key) ?? [];
    return stringIds.map((id) => int.parse(id)).toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<int> ids) async {
    await _prefs.setStringList(_key, ids.map((id) => id.toString()).toList());
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_key);
  }
}
