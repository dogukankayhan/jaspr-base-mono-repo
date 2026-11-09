import 'dart:async';
import 'package:app_shared/domain/entity/pokemon_ability_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/entity/pokemon_type_entity.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/usecase/clear_favorites_usecase.dart';
import 'package:app_shared/domain/usecase/get_favorites_usecase.dart';
import 'package:app_shared/domain/usecase/remove_favorite_usecase.dart';
import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_bloc.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pokemon_favorites_bloc_test.mocks.dart';

@GenerateMocks([
  GetFavoritesUseCase,
  RemoveFavoriteUseCase,
  ClearFavoritesUseCase,
  FavoritesRepository,
])
void main() {
  late MockGetFavoritesUseCase mockGetFavoritesUseCase;
  late MockRemoveFavoriteUseCase mockRemoveFavoriteUseCase;
  late MockClearFavoritesUseCase mockClearFavoritesUseCase;
  late MockFavoritesRepository mockFavoritesRepo;
  late PokemonFavoritesBloc bloc;

  final tPokemon = const Pokemon(
    id: 1,
    name: 'bulbasaur',
    height: 7,
    weight: 69,
    baseExperience: 64,
    types: [
      PokemonType(
        slot: 1,
        type: TypeInfo(name: 'grass', url: ''),
      ),
    ],
    abilities: [
      PokemonAbility(
        isHidden: false,
        slot: 1,
        ability: AbilityInfo(name: 'overgrow', url: ''),
      ),
    ],
    stats: PokemonStats(
      hp: 45,
      attack: 49,
      defense: 49,
      specialAttack: 65,
      specialDefense: 65,
      speed: 45,
    ),
    sprites: PokemonSprites(frontDefault: 'sprite_url'),
    speciesName: 'bulbasaur',
    speciesUrl: 'species_url',
  );

  setUp(() {
    mockGetFavoritesUseCase = MockGetFavoritesUseCase();
    mockRemoveFavoriteUseCase = MockRemoveFavoriteUseCase();
    mockClearFavoritesUseCase = MockClearFavoritesUseCase();
    mockFavoritesRepo = MockFavoritesRepository();

    when(
      mockFavoritesRepo.favoriteIdsStream,
    ).thenAnswer((_) => Stream.value({}));

    bloc = PokemonFavoritesBloc(
      mockGetFavoritesUseCase,
      mockRemoveFavoriteUseCase,
      mockClearFavoritesUseCase,
      mockFavoritesRepo,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('PokemonFavoritesBloc Initial State', () {
    test('initial state has correct default values', () {
      expect(bloc.state.favorites, isEmpty);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.errorMessage, isNull);
    });
  });

  group('PokemonFavoritesLoad', () {
    test('loads favorite pokemons successfully', () async {
      when(mockGetFavoritesUseCase()).thenAnswer((_) async => [tPokemon]);

      bloc.add(PokemonFavoritesLoad());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.favorites, contains(tPokemon));
      expect(bloc.state.errorMessage, isNull);
    });

    test('emits error state when loading favorites fails', () async {
      when(mockGetFavoritesUseCase()).thenThrow(Exception('Cache error'));

      bloc.add(PokemonFavoritesLoad());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.errorMessage, contains('Cache error'));
    });
  });

  group('PokemonFavoritesRemove', () {
    test('removes favorite pokemon successfully', () async {
      when(mockGetFavoritesUseCase()).thenAnswer((_) async => [tPokemon]);
      when(mockRemoveFavoriteUseCase(1)).thenAnswer((_) async {});

      bloc.add(PokemonFavoritesLoad());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.favorites, contains(tPokemon));

      bloc.add(PokemonFavoritesRemove(1));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(mockRemoveFavoriteUseCase(1)).called(1);
      expect(bloc.state.favorites, isEmpty);
    });
  });

  group('PokemonFavoritesClearAll', () {
    test('clears all favorite pokemons successfully', () async {
      when(mockGetFavoritesUseCase()).thenAnswer((_) async => [tPokemon]);
      when(mockClearFavoritesUseCase()).thenAnswer((_) async {});

      bloc.add(PokemonFavoritesLoad());
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.favorites, contains(tPokemon));

      bloc.add(PokemonFavoritesClearAll());
      await Future.delayed(const Duration(milliseconds: 50));

      verify(mockClearFavoritesUseCase()).called(1);
      expect(bloc.state.favorites, isEmpty);
    });
  });
}
