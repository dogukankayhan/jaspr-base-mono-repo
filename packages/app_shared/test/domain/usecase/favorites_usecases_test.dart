import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/usecase/add_favorite_usecase.dart';
import 'package:app_shared/domain/usecase/clear_favorites_usecase.dart';
import 'package:app_shared/domain/usecase/get_favorites_usecase.dart';
import 'package:app_shared/domain/usecase/remove_favorite_usecase.dart';
import 'package:app_shared/domain/usecase/toggle_favorite_usecase.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_usecases_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _kPokemon = Pokemon(
  id: 1,
  name: 'bulbasaur',
  height: 7,
  weight: 69,
  types: [],
  abilities: [],
  moves: [],
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

@GenerateNiceMocks([MockSpec<FavoritesRepository>()])
void main() {
  late MockFavoritesRepository mockRepo;

  setUp(() {
    mockRepo = MockFavoritesRepository();
    when(mockRepo.favoriteIdsStream).thenAnswer((_) => Stream.value({}));
  });

  // ─── GetFavoritesUseCase ──────────────────────────────────────────────────

  group('GetFavoritesUseCase', () {
    late GetFavoritesUseCase useCase;
    setUp(() => useCase = GetFavoritesUseCase(mockRepo));

    test('delegates to repository.getFavorites', () async {
      when(mockRepo.getFavorites()).thenAnswer((_) async => [_kPokemon]);

      final result = await useCase();

      expect(result, [_kPokemon]);
      verify(mockRepo.getFavorites()).called(1);
    });

    test('returns empty list when no favorites', () async {
      when(mockRepo.getFavorites()).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });
  });

  // ─── AddFavoriteUseCase ───────────────────────────────────────────────────

  group('AddFavoriteUseCase', () {
    late AddFavoriteUseCase useCase;
    setUp(() => useCase = AddFavoriteUseCase(mockRepo));

    test('delegates to repository.addFavorite with correct id', () async {
      when(mockRepo.addFavorite(1)).thenAnswer((_) => Future.value());

      await useCase(1);

      verify(mockRepo.addFavorite(1)).called(1);
    });
  });

  // ─── RemoveFavoriteUseCase ────────────────────────────────────────────────

  group('RemoveFavoriteUseCase', () {
    late RemoveFavoriteUseCase useCase;
    setUp(() => useCase = RemoveFavoriteUseCase(mockRepo));

    test('delegates to repository.removeFavorite with correct id', () async {
      when(mockRepo.removeFavorite(1)).thenAnswer((_) => Future.value());

      await useCase(1);

      verify(mockRepo.removeFavorite(1)).called(1);
    });
  });

  // ─── ToggleFavoriteUseCase ────────────────────────────────────────────────

  group('ToggleFavoriteUseCase', () {
    late ToggleFavoriteUseCase useCase;
    setUp(() => useCase = ToggleFavoriteUseCase(mockRepo));

    test('returns true when toggled to favorite', () async {
      when(mockRepo.toggleFavorite(1)).thenAnswer((_) async => true);

      final result = await useCase(1);

      expect(result, true);
      verify(mockRepo.toggleFavorite(1)).called(1);
    });

    test('returns false when toggled off', () async {
      when(mockRepo.toggleFavorite(1)).thenAnswer((_) async => false);

      final result = await useCase(1);

      expect(result, false);
    });
  });

  // ─── ClearFavoritesUseCase ────────────────────────────────────────────────

  group('ClearFavoritesUseCase', () {
    late ClearFavoritesUseCase useCase;
    setUp(() => useCase = ClearFavoritesUseCase(mockRepo));

    test('delegates to repository.clearAll', () async {
      when(mockRepo.clearAll()).thenAnswer((_) => Future.value());

      await useCase();

      verify(mockRepo.clearAll()).called(1);
    });
  });
}
