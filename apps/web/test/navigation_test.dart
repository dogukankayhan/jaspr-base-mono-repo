import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:flutter_base_kit_web/features/pokemon_detail/pokemon_detail_navigator.dart';
import 'package:flutter_base_kit_web/features/pokemon_home/pokemon_home_navigator.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:kit_network/core/di/locator.dart';

/// Unused members throw — the page must not hit the network in this test
/// (onReady, which loads data, only runs in the browser).
class _FakePokemonRepository implements PokemonRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Stream<Set<int>> get favoriteIdsStream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Navigators own their paths (Rule 5)', () {
    test('PokemonDetailNavigator builds locations from typed params', () {
      expect(PokemonDetailNavigator.location(id: 25), '/pokemon/25');
      expect(PokemonDetailNavigator.path, '/pokemon/:id');
    });

    test('PokemonHomeNavigator encodes the result set in the URL', () {
      expect(PokemonHomeNavigator.location(), '/');
      expect(PokemonHomeNavigator.location(query: '  '), '/');
      expect(PokemonHomeNavigator.location(query: 'mr mime'), '/?q=mr+mime');
      expect(PokemonHomeNavigator.location(type: 'fire'), '/?type=fire');
      // A type filter wins over a search, like in the bloc.
      expect(
        PokemonHomeNavigator.location(query: 'char', type: 'fire'),
        '/?type=fire',
      );
    });
  });

  group('PokemonHomePage', () {
    setUp(() {
      getIt
        ..registerSingleton<PokemonRepository>(_FakePokemonRepository())
        ..registerSingleton<FavoritesRepository>(_FakeFavoritesRepository());
    });
    tearDown(getIt.reset);

    testComponents('renders the search field and every type filter', (
      tester,
    ) async {
      tester.pumpComponent(Router(routes: [PokemonHomeNavigator.route]));
      await tester.pump();

      expect(find.tag('input'), findsOneComponent);
      expect(find.text('Fire'), findsOneComponent);
      expect(find.text('Fighting'), findsOneComponent);
    });
  });
}
