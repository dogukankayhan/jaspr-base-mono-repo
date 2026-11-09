import 'dart:async';

import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:app_shared/data/datasource/favorites_local_datasource.dart';
import 'package:app_shared/data/repository/favorites_repository_impl.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_repository_impl_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _kPokemon = Pokemon(
  id: 1,
  name: 'bulbasaur',
  height: 7,
  weight: 69,
  types: [],
  abilities: [],
  stats: PokemonStats(
    hp: 45,
    attack: 49,
    defense: 49,
    specialAttack: 65,
    specialDefense: 65,
    speed: 45,
  ),
  sprites: PokemonSprites(),
  speciesName: 'bulbasaur',
  speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
);

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateNiceMocks([MockSpec<FavoritesLocalDataSource>()])
@GenerateMocks([PokemonRepository])
void main() {
  late MockFavoritesLocalDataSource mockDs;
  late MockPokemonRepository mockPokemonRepo;
  late FavoritesRepositoryImpl repo;

  setUp(() {
    provideDummy<Result<Pokemon, ApiError>>(const Ok(_kPokemon));
    provideDummy<Result<(List<Pokemon>, bool, int), ApiError>>(
      const Ok(([], false, 0)),
    );
    mockDs = MockFavoritesLocalDataSource();
    mockPokemonRepo = MockPokemonRepository();
    // Constructor broadcasts initial state — stub before creation
    when(mockDs.getFavoriteIds()).thenAnswer((_) async => {});
    repo = FavoritesRepositoryImpl(
      localDataSource: mockDs,
      pokemonRepository: mockPokemonRepo,
    );
  });

  tearDown(() => repo.dispose());

  // ─── favoriteIdsStream ─────────────────────────────────────────────────────

  group('favoriteIdsStream', () {
    test('emits initial favorites set on construction', () async {
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {1, 2});
      final repo2 = FavoritesRepositoryImpl(
        localDataSource: mockDs,
        pokemonRepository: mockPokemonRepo,
      );
      addTearDown(repo2.dispose);

      expect(await repo2.favoriteIdsStream.first, {1, 2});
    });

    test('emits updated set after addFavorite', () async {
      when(mockDs.addFavorite(1)).thenAnswer((_) => Future.value());
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {1});

      // Listen BEFORE the action — broadcast stream does not replay past events
      final streamFuture = expectLater(
        repo.favoriteIdsStream,
        emitsThrough(equals({1})),
      );
      await repo.addFavorite(1);
      await streamFuture;
    });
  });

  // ─── getFavorites ──────────────────────────────────────────────────────────

  group('getFavorites', () {
    test('fetches all favorites in parallel and keeps their order', () async {
      final started = <int>[];
      final gates = {1: Completer<void>(), 2: Completer<void>()};
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {2, 1});
      when(mockPokemonRepo.getById(any)).thenAnswer((inv) async {
        final id = inv.positionalArguments.first as int;
        started.add(id);
        await gates[id]!.future;
        return Ok(
          Pokemon(
            id: id,
            name: 'p\$id',
            height: 0,
            weight: 0,
            types: const [],
            abilities: const [],
            stats: _kPokemon.stats,
            sprites: _kPokemon.sprites,
            speciesName: '',
            speciesUrl: '',
          ),
        );
      });

      final future = repo.getFavorites();
      await Future<void>.delayed(Duration.zero);
      // Both requests are in flight before either finishes.
      expect(started, [2, 1]);

      gates[1]!.complete(); // finishes first…
      gates[2]!.complete();
      final result = await future;
      expect(result.map((p) => p.id), [2, 1]); // …but order is preserved
    });

    test('returns empty list when no favorites stored', () async {
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {});

      final result = await repo.getFavorites();

      expect(result, isEmpty);
    });

    test('fetches pokemon for each stored id', () async {
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {1});
      when(
        mockPokemonRepo.getById(1),
      ).thenAnswer((_) async => const Ok(_kPokemon));

      final result = await repo.getFavorites();

      expect(result, [_kPokemon]);
      verify(mockPokemonRepo.getById(1)).called(1);
    });

    test('skips ids that return Err from pokemon repository', () async {
      final error = ApiError(message: 'not found');
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {1});
      when(mockPokemonRepo.getById(1)).thenAnswer((_) async => Err(error));

      final result = await repo.getFavorites();

      expect(result, isEmpty);
    });
  });

  // ─── addFavorite ───────────────────────────────────────────────────────────

  group('addFavorite', () {
    test('delegates to datasource', () async {
      when(mockDs.addFavorite(7)).thenAnswer((_) => Future.value());
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {7});

      await repo.addFavorite(7);

      verify(mockDs.addFavorite(7)).called(1);
    });
  });

  // ─── removeFavorite ────────────────────────────────────────────────────────

  group('removeFavorite', () {
    test('delegates to datasource', () async {
      when(mockDs.removeFavorite(7)).thenAnswer((_) => Future.value());
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {});

      await repo.removeFavorite(7);

      verify(mockDs.removeFavorite(7)).called(1);
    });
  });

  // ─── isFavorite ────────────────────────────────────────────────────────────

  group('isFavorite', () {
    test('returns true when id is favorite', () async {
      when(mockDs.isFavorite(1)).thenAnswer((_) async => true);

      expect(await repo.isFavorite(1), true);
    });

    test('returns false when id is not favorite', () async {
      when(mockDs.isFavorite(99)).thenAnswer((_) async => false);

      expect(await repo.isFavorite(99), false);
    });
  });

  // ─── toggleFavorite ────────────────────────────────────────────────────────

  group('toggleFavorite', () {
    test('returns true when toggled on', () async {
      when(mockDs.toggleFavorite(1)).thenAnswer((_) async => true);
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {1});

      final result = await repo.toggleFavorite(1);

      expect(result, true);
      verify(mockDs.toggleFavorite(1)).called(1);
    });

    test('returns false when toggled off', () async {
      when(mockDs.toggleFavorite(1)).thenAnswer((_) async => false);
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {});

      final result = await repo.toggleFavorite(1);

      expect(result, false);
    });
  });

  // ─── getFavoriteIds ────────────────────────────────────────────────────────

  group('getFavoriteIds', () {
    test('delegates to datasource', () async {
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {1, 2, 3});

      final ids = await repo.getFavoriteIds();

      expect(ids, {1, 2, 3});
    });
  });

  // ─── clearAll ──────────────────────────────────────────────────────────────

  group('clearAll', () {
    test('delegates to datasource', () async {
      when(mockDs.clearAll()).thenAnswer((_) => Future.value());
      when(mockDs.getFavoriteIds()).thenAnswer((_) async => {});

      await repo.clearAll();

      verify(mockDs.clearAll()).called(1);
    });
  });

  // ─── dispose ───────────────────────────────────────────────────────────────

  group('dispose', () {
    test('closes the stream controller', () async {
      final repo2 = FavoritesRepositoryImpl(
        localDataSource: mockDs,
        pokemonRepository: mockPokemonRepo,
      );
      // Pump the event loop so the constructor's async _emitCurrentFavorites()
      // completes before we close the stream — otherwise it crashes on .add()
      // to an already-closed StreamController.
      await Future.delayed(Duration.zero);

      final doneCompleter = Completer<void>();
      repo2.favoriteIdsStream.listen((_) {}, onDone: doneCompleter.complete);

      repo2.dispose();

      await doneCompleter.future;
    });
  });
}
