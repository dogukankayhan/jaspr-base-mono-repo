import 'dart:async';
import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_ability_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_species_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/entity/pokemon_type_entity.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/usecase/get_evolution_chain_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_by_id_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_species_usecase.dart';
import 'package:app_shared/features/pokemon_detail/bloc/detail_bloc.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detail_bloc_test.mocks.dart';

@GenerateMocks([
  GetPokemonByIdUseCase,
  GetPokemonSpeciesUseCase,
  GetEvolutionChainUseCase,
  FavoritesRepository,
])
void main() {
  late MockGetPokemonByIdUseCase mockGetPokemonByIdUseCase;
  late MockGetPokemonSpeciesUseCase mockGetPokemonSpeciesUseCase;
  late MockGetEvolutionChainUseCase mockGetEvolutionChainUseCase;
  late MockFavoritesRepository mockFavoritesRepo;
  late DetailBloc bloc;

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

  const tSpecies = PokemonSpecies(
    id: 1,
    name: 'bulbasaur',
    description: 'A strange seed was planted on its back.',
    genus: 'Seed Pokémon',
    eggGroups: ['Monster', 'Grass'],
    genderRate: 1,
    evolutionChainUrl: 'evolution_url',
  );

  const tEvolutionChain = EvolutionChain(
    id: 1,
    root: EvolutionNode(speciesName: 'bulbasaur', speciesId: 1, evolvesTo: []),
  );

  setUp(() {
    mockGetPokemonByIdUseCase = MockGetPokemonByIdUseCase();
    mockGetPokemonSpeciesUseCase = MockGetPokemonSpeciesUseCase();
    mockGetEvolutionChainUseCase = MockGetEvolutionChainUseCase();
    mockFavoritesRepo = MockFavoritesRepository();

    when(
      mockFavoritesRepo.favoriteIdsStream,
    ).thenAnswer((_) => Stream.value({}));

    bloc = DetailBloc(
      getPokemonByIdUseCase: mockGetPokemonByIdUseCase,
      getPokemonSpeciesUseCase: mockGetPokemonSpeciesUseCase,
      getEvolutionChainUseCase: mockGetEvolutionChainUseCase,
      favoritesRepo: mockFavoritesRepo,
      initialPokemon: tPokemon,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('DetailBloc Initial State', () {
    test('initial state has correct default values', () {
      expect(bloc.state.pokemon, tPokemon);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.isFavorite, false);
      expect(bloc.state.errorMessage, isNull);
    });
  });

  group('DetailLoad', () {
    test('loads details successfully', () async {
      when(mockGetPokemonByIdUseCase(1)).thenAnswer((_) async => tPokemon);
      when(mockFavoritesRepo.isFavorite(1)).thenAnswer((_) async => true);
      when(
        mockGetPokemonSpeciesUseCase('species_url'),
      ).thenAnswer((_) async => tSpecies);
      when(
        mockGetEvolutionChainUseCase('evolution_url'),
      ).thenAnswer((_) async => tEvolutionChain);

      bloc.add(DetailLoad(1));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.pokemon, tPokemon);
      expect(bloc.state.isFavorite, true);
      expect(bloc.state.species, tSpecies);
      expect(bloc.state.evolutionChain, tEvolutionChain);
    });

    test('emits error state when loading fails', () async {
      when(mockGetPokemonByIdUseCase(1)).thenThrow(Exception('Server error'));
      when(mockFavoritesRepo.isFavorite(1)).thenAnswer((_) async => false);

      bloc.add(DetailLoad(1));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.errorMessage, contains('Server error'));
    });
  });

  group('DetailToggleFavorite', () {
    test('toggles favorite status successfully', () async {
      when(mockGetPokemonByIdUseCase(1)).thenAnswer((_) async => tPokemon);
      when(mockFavoritesRepo.isFavorite(1)).thenAnswer((_) async => false);
      when(mockFavoritesRepo.toggleFavorite(1)).thenAnswer((_) async => true);

      // Load first to set currentPokemonId
      bloc.add(DetailLoad(1));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(DetailToggleFavorite());
      await Future.delayed(const Duration(milliseconds: 50));

      verify(mockFavoritesRepo.toggleFavorite(1)).called(1);
    });
  });
}
