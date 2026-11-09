import 'package:app_shared/data/dto/evolution_chain_dto.dart';
import 'package:app_shared/data/dto/pokemon_brief_dto.dart';
import 'package:app_shared/data/dto/pokemon_dto.dart';
import 'package:app_shared/data/dto/pokemon_species_dto.dart';
import 'package:app_shared/data/dto/pokemon_sprites_dto.dart';
import 'package:app_shared/data/dto/pokemon_stats_dto.dart';
import 'package:app_shared/data/repository/pokemon_repository_impl.dart';
import 'package:app_shared/domain/entity/pokemon_brief_entity.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/api/api_response.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/network/error/api_exception.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pokemon_repository_impl_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _kBriefDto = PokemonBriefDto(
  name: 'bulbasaur',
  url: 'https://pokeapi.co/api/v2/pokemon/1/',
);

final _kPokemonDto = PokemonDto(
  id: 1,
  name: 'bulbasaur',
  height: 7,
  weight: 69,
  types: const [],
  abilities: const [],
  stats: PokemonStatsDto(
    hp: 45,
    attack: 49,
    defense: 49,
    specialAttack: 65,
    specialDefense: 65,
    speed: 45,
  ),
  sprites: PokemonSpritesDto(),
  moves: const [],
  speciesName: 'bulbasaur',
  speciesUrl: 'https://pokeapi.co/api/v2/pokemon-species/1/',
);

final _kSpeciesDto = PokemonSpeciesDto(
  id: 1,
  name: 'bulbasaur',
  description: 'A strange seed',
  genus: 'Seed Pokémon',
  eggGroups: const [],
  genderRate: 1,
  evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/1/',
);

final _kEvolutionDto = EvolutionChainDto(
  id: 1,
  root: EvolutionNodeDto(
    speciesName: 'bulbasaur',
    speciesId: 1,
    evolvesTo: const [],
  ),
);

ApiException _makeException([String msg = 'network error']) =>
    ApiException(ApiError(message: msg));

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([ApiManager])
void main() {
  late MockApiManager mockApi;
  late PokemonRepositoryImpl repo;

  setUp(() {
    mockApi = MockApiManager();
    repo = PokemonRepositoryImpl(mockApi);
  });

  void stubList(List<PokemonBriefDto> briefs) {
    when(
      mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
        any,
        fromJson: anyNamed('fromJson'),
        method: anyNamed('method'),
        queryParameters: anyNamed('queryParameters'),
        listWrapperKey: anyNamed('listWrapperKey'),
      ),
    ).thenAnswer((_) async => ApiResponse(data: briefs));
  }

  void stubDetail(PokemonDto pokemon) {
    when(
      mockApi.get<PokemonDto>(
        path: anyNamed('path'),
        fromJson: anyNamed('fromJson'),
      ),
    ).thenAnswer((_) async => ApiResponse(data: pokemon));
  }

  // ─── pageWithSize ──────────────────────────────────────────────────────────

  group('pageWithSize', () {
    test('returns Ok with correct items and offset on full page', () async {
      stubList(List.filled(20, _kBriefDto));
      stubDetail(_kPokemonDto);

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items.length, 20);
          expect(hasMore, true);
          expect(offset, 20);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test(
      'hasMore=false when returned list is smaller than requested size',
      () async {
        stubList([_kBriefDto]);
        stubDetail(_kPokemonDto);

        final result = await repo.pageWithSize(20, 0);

        result.when(
          ok: (data) => expect(data.$2, false),
          err: (_) => fail('expected ok'),
        );
      },
    );

    test('hasMore=false on empty list', () async {
      stubList([]);

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items, isEmpty);
          expect(hasMore, false);
          expect(offset, 0);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err wrapping ApiError from ApiException', () async {
      when(
        mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          any,
          fromJson: anyNamed('fromJson'),
          method: anyNamed('method'),
          queryParameters: anyNamed('queryParameters'),
          listWrapperKey: anyNamed('listWrapperKey'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });

    test('wraps generic exception as Err(ApiError)', () async {
      when(
        mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          any,
          fromJson: anyNamed('fromJson'),
          method: anyNamed('method'),
          queryParameters: anyNamed('queryParameters'),
          listWrapperKey: anyNamed('listWrapperKey'),
        ),
      ).thenThrow(Exception('timeout'));

      final result = await repo.pageWithSize(20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, contains('timeout')),
      );
    });
  });

  // ─── page ──────────────────────────────────────────────────────────────────

  group('page', () {
    test('delegates to pageWithSize with default pageSize=20', () async {
      stubList([_kBriefDto]);
      stubDetail(_kPokemonDto);

      await repo.page(0);

      verify(
        mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          'pokemon',
          fromJson: anyNamed('fromJson'),
          method: RequestMethod.get,
          queryParameters: {'limit': 20, 'offset': 0},
          listWrapperKey: 'results',
        ),
      ).called(1);
    });
  });

  // ─── pageByType ────────────────────────────────────────────────────────────

  group('pageByType', () {
    test('returns first slice with hasMore=true when more exist', () async {
      when(
        mockApi.get<List<PokemonBriefDto>>(
          path: 'type/grass',
          extractor: anyNamed('extractor'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: List.filled(3, _kBriefDto)));
      stubDetail(_kPokemonDto);

      final result = await repo.pageByType('grass', 2, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items.length, 2);
          expect(hasMore, true);
          expect(offset, 2);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('hasMore=false on last slice', () async {
      when(
        mockApi.get<List<PokemonBriefDto>>(
          path: 'type/grass',
          extractor: anyNamed('extractor'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: [_kBriefDto, _kBriefDto]));
      stubDetail(_kPokemonDto);

      final result = await repo.pageByType('grass', 5, 0);

      result.when(
        ok: (data) => expect(data.$2, false),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<List<PokemonBriefDto>>(
          path: 'type/fire',
          extractor: anyNamed('extractor'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.pageByType('fire', 20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── pageSearch ────────────────────────────────────────────────────────────

  group('pageSearch', () {
    test('returns matching results with correct pagination', () async {
      stubList([_kBriefDto]);
      stubDetail(_kPokemonDto);

      final result = await repo.pageSearch('bulb', 20, 0);

      result.when(
        ok: (data) {
          final (items, hasMore, offset) = data;
          expect(items.map((p) => p.name), ['bulbasaur']);
          expect(hasMore, false);
          expect(offset, 1);
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          any,
          fromJson: anyNamed('fromJson'),
          method: anyNamed('method'),
          queryParameters: anyNamed('queryParameters'),
          listWrapperKey: anyNamed('listWrapperKey'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.pageSearch('bad', 20, 0);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getById ───────────────────────────────────────────────────────────────

  group('getById', () {
    test('converts id to string and calls the detail endpoint', () async {
      stubDetail(_kPokemonDto);

      final result = await repo.getById(1);

      result.when(ok: (p) => expect(p.id, 1), err: (_) => fail('expected ok'));
      verify(
        mockApi.get<PokemonDto>(
          path: 'pokemon/1',
          fromJson: anyNamed('fromJson'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<PokemonDto>(
          path: anyNamed('path'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.getById(99);

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getByName ─────────────────────────────────────────────────────────────

  group('getByName', () {
    test('returns Ok with pokemon on success', () async {
      stubDetail(_kPokemonDto);

      final result = await repo.getByName('bulbasaur');

      result.when(
        ok: (p) => expect(p.name, 'bulbasaur'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<PokemonDto>(
          path: anyNamed('path'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.getByName('unknown');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getSpecies ────────────────────────────────────────────────────────────

  group('getSpecies', () {
    test('extracts id from url and returns Ok', () async {
      const url = 'https://pokeapi.co/api/v2/pokemon-species/1/';
      when(
        mockApi.get<PokemonSpeciesDto>(
          path: 'pokemon-species/1',
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kSpeciesDto));

      final result = await repo.getSpecies(url);

      result.when(
        ok: (s) => expect(s.name, 'bulbasaur'),
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<PokemonSpeciesDto>(
          path: anyNamed('path'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.getSpecies('bad-url');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── getEvolutionChain ─────────────────────────────────────────────────────

  group('getEvolutionChain', () {
    test('extracts id from url and returns Ok', () async {
      const url = 'https://pokeapi.co/api/v2/evolution-chain/1/';
      when(
        mockApi.get<EvolutionChainDto>(
          path: 'evolution-chain/1',
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => ApiResponse(data: _kEvolutionDto));

      final result = await repo.getEvolutionChain(url);

      result.when(
        ok: (e) {
          expect(e.id, 1);
          expect(e.root.speciesName, 'bulbasaur');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<EvolutionChainDto>(
          path: anyNamed('path'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.getEvolutionChain('bad-url');

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  // ─── listAll ───────────────────────────────────────────────────────────────

  group('listAll', () {
    test('returns every brief once and caches it for search', () async {
      stubList([_kBriefDto]);

      final first = await repo.listAll();
      final second = await repo.listAll();
      await repo.pageSearch('zzz', 20, 0);

      expect(first.when(ok: (l) => l.length, err: (_) => -1), 1);
      expect(second.when(ok: (l) => l.length, err: (_) => -1), 1);
      // One network call for listAll ×2 + search (shared cache).
      verify(
        mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          any,
          fromJson: anyNamed('fromJson'),
          method: anyNamed('method'),
          queryParameters: anyNamed('queryParameters'),
          listWrapperKey: anyNamed('listWrapperKey'),
        ),
      ).called(1);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          any,
          fromJson: anyNamed('fromJson'),
          method: anyNamed('method'),
          queryParameters: anyNamed('queryParameters'),
          listWrapperKey: anyNamed('listWrapperKey'),
        ),
      ).thenThrow(_makeException());

      final result = await repo.listAll();
      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'network error'),
      );
    });
  });

  test('PokemonBrief.id parses the trailing URL segment', () {
    expect(
      const PokemonBrief(
        name: 'x',
        url: 'https://pokeapi.co/api/v2/pokemon/6/',
      ).id,
      6,
    );
    expect(const PokemonBrief(name: 'x', url: 'oops').id, isNull);
  });
}
