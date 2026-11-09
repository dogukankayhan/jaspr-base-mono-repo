import 'dart:async';
import 'package:app_shared/domain/entity/pokemon_ability_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/entity/pokemon_type_entity.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/usecase/filter_pokemon_by_type_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_page_usecase.dart';
import 'package:app_shared/domain/usecase/search_pokemon_usecase.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_bloc.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_state.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pokemon_home_bloc_test.mocks.dart';

@GenerateMocks([
  GetPokemonPageUseCase,
  FilterPokemonByTypeUseCase,
  SearchPokemonUseCase,
  FavoritesRepository,
])
void main() {
  late MockGetPokemonPageUseCase mockGetPageUseCase;
  late MockFilterPokemonByTypeUseCase mockFilterUseCase;
  late MockSearchPokemonUseCase mockSearchUseCase;
  late MockFavoritesRepository mockFavoritesRepo;
  late PokemonHomeBloc bloc;

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
    mockGetPageUseCase = MockGetPokemonPageUseCase();
    mockFilterUseCase = MockFilterPokemonByTypeUseCase();
    mockSearchUseCase = MockSearchPokemonUseCase();
    mockFavoritesRepo = MockFavoritesRepository();

    when(
      mockFavoritesRepo.favoriteIdsStream,
    ).thenAnswer((_) => Stream.value({}));

    bloc = PokemonHomeBloc(
      mockGetPageUseCase,
      mockFilterUseCase,
      mockSearchUseCase,
      mockFavoritesRepo,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('PokemonHomeBloc Initial State', () {
    test('initial state has correct default values', () {
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.hasMore, true);
      expect(bloc.state.nextOffset, 0);
      expect(bloc.state.selectedType, isNull);
      expect(bloc.state.searchQuery, isNull);
    });
  });

  group('PokemonHomeStarted', () {
    test('loads initial page of pokemons successfully', () async {
      when(
        mockGetPageUseCase(size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], true, 20));

      final loadingStates = <bool>[];
      final subscription = bloc.stream.listen(
        (s) => loadingStates.add(s.isLoading),
      );

      bloc.add(PokemonHomeStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(loadingStates, containsAll([true, false]));
      expect(bloc.state.items, contains(tPokemon));
      expect(bloc.state.hasMore, true);
      expect(bloc.state.nextOffset, 20);

      await subscription.cancel();
    });

    test('emits error state when loading page fails', () async {
      when(
        mockGetPageUseCase(size: 20, offset: 0),
      ).thenThrow(Exception('Network error'));

      bloc.add(PokemonHomeStarted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isLoading, false);
      expect(bloc.state.errorMessage, contains('Network error'));
    });
  });

  group('PokemonHomeFilterByType', () {
    test('loads pokemons filtered by type', () async {
      when(
        mockFilterUseCase(type: 'grass', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeFilterByType('grass'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.selectedType, 'grass');
      expect(bloc.state.items, contains(tPokemon));
      expect(bloc.state.hasMore, false);
    });
  });

  group('PokemonHomeSearch', () {
    test('loads searched pokemons', () async {
      when(
        mockSearchUseCase(query: 'bulb', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeSearch('bulb'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.searchQuery, 'bulb');
      expect(bloc.state.items, contains(tPokemon));
    });
  });
  // ─── Behaviour shared by mobile + web ───────────────────────────────────────

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  group('PokemonHomeFilterByType — toggling', () {
    test('selecting the active type again clears the filter', () async {
      when(
        mockFilterUseCase(type: 'fire', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));
      when(
        mockGetPageUseCase(size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], true, 20));

      bloc.add(PokemonHomeFilterByType('fire'));
      await settle();
      expect(bloc.state.selectedType, 'fire');

      bloc.add(PokemonHomeFilterByType('fire'));
      await settle();
      expect(bloc.state.selectedType, isNull);
      verify(mockGetPageUseCase(size: 20, offset: 0)).called(1);
    });

    test('a type filter replaces an active search', () async {
      when(
        mockSearchUseCase(query: 'char', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));
      when(
        mockFilterUseCase(type: 'fire', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeSearch('char'));
      await settle();
      bloc.add(PokemonHomeFilterByType('fire'));
      await settle();

      expect(bloc.state.searchQuery, isNull);
      expect(bloc.state.selectedType, 'fire');
    });
  });

  group('resultsVersion (views reset scroll on change)', () {
    test('bumps on search, filter and clear — not on load more', () async {
      when(
        mockSearchUseCase(query: 'a', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], true, 1));
      when(
        mockSearchUseCase(query: 'a', size: 20, offset: 1),
      ).thenAnswer((_) async => ([tPokemon], false, 2));
      when(
        mockFilterUseCase(type: 'ice', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));
      when(
        mockGetPageUseCase(size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], true, 20));

      final v0 = bloc.state.resultsVersion;
      bloc.add(PokemonHomeSearch('a'));
      await settle();
      expect(bloc.state.resultsVersion, v0 + 1);

      bloc.add(PokemonHomeLoadMore());
      await settle();
      expect(bloc.state.items.length, 2);
      expect(bloc.state.resultsVersion, v0 + 1);

      bloc.add(PokemonHomeFilterByType('ice'));
      await settle();
      bloc.add(PokemonHomeClearFilters());
      await settle();
      expect(bloc.state.resultsVersion, v0 + 3);
      expect(bloc.state.hasActiveQuery, isFalse);
    });
  });

  group('PokemonHomeSearchQueryChanged — debounce', () {
    test(
      'only the last keystroke within the window triggers a search',
      () async {
        when(
          mockSearchUseCase(query: anyNamed('query'), size: 20, offset: 0),
        ).thenAnswer((_) async => ([tPokemon], false, 1));

        bloc.add(PokemonHomeSearchQueryChanged('p'));
        bloc.add(PokemonHomeSearchQueryChanged('pi'));
        bloc.add(PokemonHomeSearchQueryChanged('pika'));
        await Future<void>.delayed(
          PokemonHomeBloc.searchDebounceDuration +
              const Duration(milliseconds: 50),
        );

        verify(mockSearchUseCase(query: 'pika', size: 20, offset: 0)).called(1);
        verifyNever(mockSearchUseCase(query: 'p', size: 20, offset: 0));
        expect(bloc.state.searchQuery, 'pika');
      },
    );

    test(
      'a type filter tapped while typing cancels the pending search',
      () async {
        when(
          mockFilterUseCase(type: 'water', size: 20, offset: 0),
        ).thenAnswer((_) async => ([tPokemon], false, 1));

        bloc.add(PokemonHomeSearchQueryChanged('squ'));
        bloc.add(PokemonHomeFilterByType('water'));
        await Future<void>.delayed(
          PokemonHomeBloc.searchDebounceDuration +
              const Duration(milliseconds: 50),
        );

        verifyNever(mockSearchUseCase(query: 'squ', size: 20, offset: 0));
        expect(bloc.state.selectedType, 'water');
      },
    );
  });

  group('PokemonHomeStarted — restoring a result set (web URL)', () {
    test('restores a search', () async {
      when(
        mockSearchUseCase(query: 'eevee', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeStarted(query: '  eevee '));
      await settle();

      expect(bloc.state.searchQuery, 'eevee');
      expect(bloc.state.items, [tPokemon]);
    });

    test('a type wins over a query', () async {
      when(
        mockFilterUseCase(type: 'grass', size: 20, offset: 0),
      ).thenAnswer((_) async => ([tPokemon], false, 1));

      bloc.add(PokemonHomeStarted(query: 'bulb', type: 'grass'));
      await settle();

      expect(bloc.state.selectedType, 'grass');
      expect(bloc.state.searchQuery, isNull);
    });
  });

  group('state helpers', () {
    test('isEmptyResult only after a finished, empty query', () async {
      when(
        mockSearchUseCase(query: 'zzz', size: 20, offset: 0),
      ).thenAnswer((_) async => (<Pokemon>[], false, 0));

      expect(bloc.state.isEmptyResult, isFalse);
      bloc.add(PokemonHomeSearch('zzz'));
      await settle();
      expect(bloc.state.isEmptyResult, isTrue);
    });
  });
  group('initialState (SSR hydration)', () {
    test(
      'starts from the seeded page and continues paginating from it',
      () async {
        final seeded = PokemonHomeBloc(
          mockGetPageUseCase,
          mockFilterUseCase,
          mockSearchUseCase,
          mockFavoritesRepo,
          initialState: PokemonHomeState(
            items: [tPokemon],
            hasMore: true,
            nextOffset: 20,
          ),
        );
        when(
          mockGetPageUseCase(size: 20, offset: 20),
        ).thenAnswer((_) async => ([tPokemon], false, 21));

        expect(seeded.state.items, [tPokemon]);

        seeded.add(PokemonHomeLoadMore());
        await settle();

        verify(mockGetPageUseCase(size: 20, offset: 20)).called(1);
        verifyNever(
          mockGetPageUseCase(size: 20, offset: 0),
        ); // no refetch of page 1
        expect(seeded.state.items.length, 2);
        await seeded.close();
      },
    );
  });
}
