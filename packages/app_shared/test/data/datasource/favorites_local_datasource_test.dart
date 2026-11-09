import 'package:app_shared/data/datasource/favorites_local_datasource.dart';
import 'package:test/test.dart';

/// Minimal in-memory subclass — exercises the shared add/remove/toggle logic
/// that both the mobile (shared_preferences) and web (localStorage) stores use.
class _InMemoryFavorites extends FavoritesLocalDataSource {
  Set<int> stored = {};

  @override
  Future<Set<int>> getFavoriteIds() async => {...stored};

  @override
  Future<void> saveFavoriteIds(Set<int> ids) async => stored = {...ids};

  @override
  Future<void> clearAll() async => stored = {};
}

void main() {
  late _InMemoryFavorites ds;

  setUp(() => ds = _InMemoryFavorites());

  test(
    'addFavorite / removeFavorite persist through saveFavoriteIds',
    () async {
      await ds.addFavorite(1);
      await ds.addFavorite(4);
      expect(ds.stored, {1, 4});

      await ds.removeFavorite(1);
      expect(ds.stored, {4});
    },
  );

  test('isFavorite reflects stored ids', () async {
    await ds.addFavorite(7);
    expect(await ds.isFavorite(7), isTrue);
    expect(await ds.isFavorite(8), isFalse);
  });

  test('toggleFavorite flips state and returns the new value', () async {
    expect(await ds.toggleFavorite(25), isTrue);
    expect(ds.stored, {25});
    expect(await ds.toggleFavorite(25), isFalse);
    expect(ds.stored, isEmpty);
  });

  test('clearAll empties the store', () async {
    await ds.addFavorite(1);
    await ds.clearAll();
    expect(await ds.getFavoriteIds(), isEmpty);
  });
}
