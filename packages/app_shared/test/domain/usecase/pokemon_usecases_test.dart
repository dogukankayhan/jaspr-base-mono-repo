import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_species_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:app_shared/domain/usecase/filter_pokemon_by_type_usecase.dart';
import 'package:app_shared/domain/usecase/get_evolution_chain_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_by_id_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_by_name_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_page_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_species_usecase.dart';
import 'package:app_shared/domain/usecase/search_pokemon_usecase.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pokemon_usecases_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _kStats = PokemonStats(
  hp: 45,
  attack: 49,
  defense: 49,
  specialAttack: 65,
  specialDefense: 65,
  speed: 45,
);

const _kPokemon = Pokemon(
  id: 1,
  name: 'bulbasaur',
  height: 7,
  weight: 69,
  types: [],
  abilities: [],
  stats: _kStats,
  sprites: PokemonSprites(),
  speciesName: 'bulbasaur',
  speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
);

const _kSpecies = PokemonSpecies(
  id: 1,
  name: 'bulbasaur',
  description: 'A strange seed',
  genus: 'Seed Pokémon',
  eggGroups: [],
  genderRate: 1,
  evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
);

const _kEvolution = EvolutionChain(
  id: 1,
  root: EvolutionNode(speciesName: 'bulbasaur', speciesId: 1, evolvesTo: []),
);

final _kError = ApiError(message: 'network error');

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([PokemonRepository])
void main() {
  late MockPokemonRepository mockRepo;

  setUp(() {
    provideDummy<Result<(List<Pokemon>, bool, int), ApiError>>(
      const Ok(([], false, 0)),
    );
    provideDummy<Result<Pokemon, ApiError>>(const Ok(_kPokemon));
    provideDummy<Result<PokemonSpecies, ApiError>>(const Ok(_kSpecies));
    provideDummy<Result<EvolutionChain, ApiError>>(const Ok(_kEvolution));
    mockRepo = MockPokemonRepository();
  });

  // ─── GetPokemonPageUseCase ────────────────────────────────────────────────

  group('GetPokemonPageUseCase', () {
    late GetPokemonPageUseCase useCase;
    setUp(() => useCase = GetPokemonPageUseCase(mockRepo));

    test('returns page data on ok', () async {
      when(
        mockRepo.pageWithSize(20, 0),
      ).thenAnswer((_) async => const Ok(([_kPokemon], true, 20)));

      final (items, hasMore, offset) = await useCase(size: 20, offset: 0);

      expect(items, [_kPokemon]);
      expect(hasMore, true);
      expect(offset, 20);
    });

    test('throws ApiError on err', () async {
      when(mockRepo.pageWithSize(20, 0)).thenAnswer((_) async => Err(_kError));

      expect(
        () => useCase(size: 20, offset: 0),
        throwsA(
          isA<ApiError>().having((e) => e.message, 'message', 'network error'),
        ),
      );
    });
  });

  // ─── GetPokemonByIdUseCase ────────────────────────────────────────────────

  group('GetPokemonByIdUseCase', () {
    late GetPokemonByIdUseCase useCase;
    setUp(() => useCase = GetPokemonByIdUseCase(mockRepo));

    test('returns pokemon on ok', () async {
      when(mockRepo.getById(1)).thenAnswer((_) async => const Ok(_kPokemon));

      final result = await useCase(1);
      expect(result, _kPokemon);
    });

    test('throws ApiError on err', () {
      when(mockRepo.getById(1)).thenAnswer((_) async => Err(_kError));

      expect(() => useCase(1), throwsA(isA<ApiError>()));
    });

    test('keeps the HTTP status code (404 vs 5xx) when rethrowing', () async {
      when(mockRepo.getById(1)).thenAnswer(
        (_) async => Err(ApiError(message: 'Not Found', statusCode: 404)),
      );
      expect(
        () => useCase(1),
        throwsA(isA<ApiError>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });
  });

  // ─── GetPokemonByNameUseCase ──────────────────────────────────────────────

  group('GetPokemonByNameUseCase', () {
    late GetPokemonByNameUseCase useCase;
    setUp(() => useCase = GetPokemonByNameUseCase(mockRepo));

    test('returns pokemon on ok', () async {
      when(
        mockRepo.getByName('bulbasaur'),
      ).thenAnswer((_) async => const Ok(_kPokemon));

      final result = await useCase('bulbasaur');
      expect(result.name, 'bulbasaur');
    });

    test('throws ApiError on err', () {
      when(mockRepo.getByName(any)).thenAnswer((_) async => Err(_kError));

      expect(() => useCase('unknown'), throwsA(isA<ApiError>()));
    });
  });

  // ─── GetPokemonSpeciesUseCase ─────────────────────────────────────────────

  group('GetPokemonSpeciesUseCase', () {
    late GetPokemonSpeciesUseCase useCase;
    setUp(() => useCase = GetPokemonSpeciesUseCase(mockRepo));

    test('returns species on ok', () async {
      when(
        mockRepo.getSpecies(any),
      ).thenAnswer((_) async => const Ok(_kSpecies));

      final result = await useCase(
        'https://pokeapi.co/api/v2/pokemon-species/1/',
      );
      expect(result.name, 'bulbasaur');
    });

    test('throws ApiError on err', () {
      when(mockRepo.getSpecies(any)).thenAnswer((_) async => Err(_kError));

      expect(() => useCase('bad-url'), throwsA(isA<ApiError>()));
    });
  });

  // ─── GetEvolutionChainUseCase ─────────────────────────────────────────────

  group('GetEvolutionChainUseCase', () {
    late GetEvolutionChainUseCase useCase;
    setUp(() => useCase = GetEvolutionChainUseCase(mockRepo));

    test('returns evolution chain on ok', () async {
      when(
        mockRepo.getEvolutionChain(any),
      ).thenAnswer((_) async => const Ok(_kEvolution));

      final result = await useCase(
        'https://pokeapi.co/api/v2/evolution-chain/1/',
      );
      expect(result.id, 1);
      expect(result.root.speciesName, 'bulbasaur');
    });

    test('throws ApiError on err', () {
      when(
        mockRepo.getEvolutionChain(any),
      ).thenAnswer((_) async => Err(_kError));

      expect(() => useCase('bad-url'), throwsA(isA<ApiError>()));
    });
  });

  // ─── SearchPokemonUseCase ─────────────────────────────────────────────────

  group('SearchPokemonUseCase', () {
    late SearchPokemonUseCase useCase;
    setUp(() => useCase = SearchPokemonUseCase(mockRepo));

    test('returns matching pokemons on ok', () async {
      when(
        mockRepo.pageSearch('bulb', 20, 0),
      ).thenAnswer((_) async => const Ok(([_kPokemon], false, 1)));

      final (items, hasMore, offset) = await useCase(
        query: 'bulb',
        size: 20,
        offset: 0,
      );
      expect(items, [_kPokemon]);
      expect(hasMore, false);
      expect(offset, 1);
    });

    test('throws ApiError on err', () {
      when(
        mockRepo.pageSearch(any, any, any),
      ).thenAnswer((_) async => Err(_kError));

      expect(
        () => useCase(query: 'bad', size: 20, offset: 0),
        throwsA(isA<ApiError>()),
      );
    });
  });

  // ─── FilterPokemonByTypeUseCase ───────────────────────────────────────────

  group('FilterPokemonByTypeUseCase', () {
    late FilterPokemonByTypeUseCase useCase;
    setUp(() => useCase = FilterPokemonByTypeUseCase(mockRepo));

    test('returns filtered pokemons on ok', () async {
      when(
        mockRepo.pageByType('grass', 20, 0),
      ).thenAnswer((_) async => const Ok(([_kPokemon], false, 1)));

      final (items, hasMore, _) = await useCase(
        type: 'grass',
        size: 20,
        offset: 0,
      );
      expect(items, [_kPokemon]);
      expect(hasMore, false);
    });

    test('throws ApiError on err', () {
      when(
        mockRepo.pageByType(any, any, any),
      ).thenAnswer((_) async => Err(_kError));

      expect(
        () => useCase(type: 'fire', size: 20, offset: 0),
        throwsA(isA<ApiError>()),
      );
    });
  });
}
