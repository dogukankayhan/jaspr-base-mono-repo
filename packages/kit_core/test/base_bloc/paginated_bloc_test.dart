import 'dart:async';

import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_core/base_bloc/paginated_bloc.dart';
import 'package:test/test.dart';

// ─── Test doubles ────────────────────────────────────────────────────────────

class _State extends PaginatedState<String> {
  @override
  final List<String> items;
  @override
  final bool hasMore;
  @override
  final int nextOffset;

  const _State({
    this.items = const [],
    this.hasMore = true,
    this.nextOffset = 0,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  _State copyWith({
    List<String>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool clearError = false,
  }) => _State(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    nextOffset: nextOffset ?? this.nextOffset,
    isLoading: isLoading ?? this.isLoading,
    isValid: isValid ?? this.isValid,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    isLoading,
    isValid,
    errorMessage,
    items,
    hasMore,
    nextOffset,
  ];
}

sealed class _Event {}

class _Load extends _Event {}

class _LoadMore extends _Event {}

class _RemoveAt extends _Event {
  final int index;
  _RemoveAt(this.index);
}

class _RemoveWhere extends _Event {
  final bool Function(String) test;
  _RemoveWhere(this.test);
}

class _TestBloc extends BaseBloc<_Event, _State>
    with PaginatedBloc<String, _Event, _State> {
  final Future<(List<String>, bool, int)> Function(int offset, int size)
  fetcher;

  _TestBloc({required this.fetcher}) : super(const _State()) {
    on<_Load>((_, emit) => handleLoadInitial(emit));
    on<_LoadMore>((_, emit) => handleLoadMore(emit));
    on<_RemoveAt>((e, emit) => handleRemoveAt(e.index, emit));
    on<_RemoveWhere>((e, emit) => handleRemoveWhere(e.test, emit));
  }

  @override
  Future<(List<String>, bool, int)> fetchPage(int offset, int size) =>
      fetcher(offset, size);

  @override
  _State paginatedState({
    List<String>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => state.copyWith(
    items: items,
    hasMore: hasMore,
    nextOffset: nextOffset,
    isLoading: isLoading,
    errorMessage: errorMessage,
    clearError: clearError,
  );
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

_TestBloc _makeBloc(List<String> Function(int offset, int size) syncFetcher) {
  return _TestBloc(
    fetcher: (offset, size) async => (
      syncFetcher(offset, size),
      syncFetcher(offset, size).length == size,
      offset + syncFetcher(offset, size).length,
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('PaginatedBloc — handleLoadInitial', () {
    test('loads first page and updates state', () async {
      final bloc = _makeBloc((_, _) => ['a', 'b', 'c']);
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      expect(bloc.state.items, ['a', 'b', 'c']);
      expect(bloc.state.isLoading, false);
      await bloc.close();
    });

    test(
      'sets hasMore false when fewer items than pageSize returned',
      () async {
        final bloc = _TestBloc(fetcher: (_, _) async => (['only'], false, 1));
        bloc.add(_Load());
        await Future.delayed(Duration.zero);

        expect(bloc.state.hasMore, false);
        await bloc.close();
      },
    );

    test('clears previous error on reload', () async {
      var fail = true;
      final bloc = _TestBloc(
        fetcher: (_, _) async {
          if (fail) throw Exception('network error');
          return (['item'], false, 1);
        },
      );

      bloc.add(_Load());
      await Future.delayed(Duration.zero);
      expect(bloc.state.errorMessage, isNotNull);

      fail = false;
      bloc.add(_Load());
      await Future.delayed(Duration.zero);
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.items, ['item']);
      await bloc.close();
    });

    test('sets errorMessage on fetch failure', () async {
      final bloc = _TestBloc(fetcher: (_, _) async => throw Exception('boom'));
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      expect(bloc.state.errorMessage, isNotNull);
      expect(bloc.state.isLoading, false);
      await bloc.close();
    });
  });

  group('PaginatedBloc — handleLoadMore', () {
    test('appends next page to existing items', () async {
      final bloc = _TestBloc(
        fetcher: (offset, size) async {
          if (offset == 0) return (['a', 'b'], true, 2);
          return (['c', 'd'], false, 4);
        },
      );

      bloc.add(_Load());
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['a', 'b']);

      bloc.add(_LoadMore());
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['a', 'b', 'c', 'd']);
      expect(bloc.state.hasMore, false);
      await bloc.close();
    });

    test('does nothing when hasMore is false', () async {
      var fetchCount = 0;
      final bloc = _TestBloc(
        fetcher: (_, _) async {
          fetchCount++;
          return (['x'], false, 1);
        },
      );

      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      final countAfterLoad = fetchCount;
      bloc.add(_LoadMore());
      await Future.delayed(Duration.zero);

      expect(fetchCount, countAfterLoad);
      await bloc.close();
    });
  });

  group('PaginatedBloc — handleRemoveAt', () {
    test('removes item at given index', () async {
      final bloc = _makeBloc((_, _) => ['a', 'b', 'c']);
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      bloc.add(_RemoveAt(1));
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['a', 'c']);
      await bloc.close();
    });

    test('ignores out-of-range index', () async {
      final bloc = _makeBloc((_, _) => ['a', 'b']);
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      bloc.add(_RemoveAt(99));
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['a', 'b']);
      await bloc.close();
    });

    test('ignores negative index', () async {
      final bloc = _makeBloc((_, _) => ['a', 'b']);
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      bloc.add(_RemoveAt(-1));
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['a', 'b']);
      await bloc.close();
    });
  });

  group('PaginatedBloc — handleRemoveWhere', () {
    test('removes items matching predicate', () async {
      final bloc = _makeBloc((_, _) => ['apple', 'banana', 'avocado']);
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      bloc.add(_RemoveWhere((s) => s.startsWith('a')));
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['banana']);
      await bloc.close();
    });

    test('keeps all items when predicate matches none', () async {
      final bloc = _makeBloc((_, _) => ['a', 'b', 'c']);
      bloc.add(_Load());
      await Future.delayed(Duration.zero);

      bloc.add(_RemoveWhere((s) => s == 'z'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.items, ['a', 'b', 'c']);
      await bloc.close();
    });
  });

  group('PaginatedBloc — defaults', () {
    test('firstPageSize defaults to 20', () {
      final bloc = _makeBloc((_, _) => []);
      expect(bloc.firstPageSize, 20);
      bloc.close();
    });

    test('nextPageSize defaults to 20', () {
      final bloc = _makeBloc((_, _) => []);
      expect(bloc.nextPageSize, 20);
      bloc.close();
    });
  });
  // ─── Concurrency (bloc handlers run concurrently) ──────────────────────────

  group('PaginatedBloc — races', () {
    test('a reload while a page is loading is NOT dropped, and wins', () async {
      final slowFirst = Completer<(List<String>, bool, int)>();
      var call = 0;
      final bloc = _TestBloc(
        fetcher: (offset, size) {
          call++;
          if (call == 1) return slowFirst.future; // old query, still in flight
          return Future.value((['new'], false, 1)); // new query
        },
      );

      bloc.add(_Load());
      await Future<void>.delayed(Duration.zero);
      bloc.add(_Load()); // e.g. user typed a new search
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.items, ['new']);
      expect(bloc.state.isLoading, isFalse);

      // The old request finishes late — must not overwrite the new results.
      slowFirst.complete((['stale'], true, 20));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.items, ['new']);
      expect(bloc.state.hasMore, isFalse);

      await bloc.close();
    });

    test('a late load-more of the previous generation is discarded', () async {
      final slowMore = Completer<(List<String>, bool, int)>();
      var call = 0;
      final bloc = _TestBloc(
        fetcher: (offset, size) {
          call++;
          return switch (call) {
            1 => Future.value((['a1'], true, 1)), // first query, page 1
            2 => slowMore.future, //                 first query, page 2 (slow)
            _ => Future.value((['b1'], false, 1)), // second query
          };
        },
      );

      bloc.add(_Load());
      await Future<void>.delayed(Duration.zero);
      bloc.add(_LoadMore());
      await Future<void>.delayed(Duration.zero);
      bloc.add(_Load());
      await Future<void>.delayed(Duration.zero);

      slowMore.complete((['a2'], false, 2));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.items, ['b1']);

      // And the bloc is not stuck "busy": a later load-more still works.
      expect(bloc.isFetchingPage, isFalse);

      await bloc.close();
    });

    test(
      'load-more is ignored while the first page is still loading',
      () async {
        final slowFirst = Completer<(List<String>, bool, int)>();
        var calls = 0;
        final bloc = _TestBloc(
          fetcher: (offset, size) {
            calls++;
            return slowFirst.future;
          },
        );

        bloc.add(_Load());
        await Future<void>.delayed(Duration.zero);
        bloc.add(_LoadMore());
        await Future<void>.delayed(Duration.zero);

        expect(calls, 1);
        slowFirst.complete((['x'], true, 1));
        await bloc.close();
      },
    );
  });
}
