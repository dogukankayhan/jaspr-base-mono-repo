# flutter_kit_core

Core abstractions for flutter_base_kit monorepo. Provides `BaseBloc`, `BaseCubit`, `BaseBlocView`, `PaginatedBloc`, `BaseUseCase`, `BaseRepository`, and the form validator system.

## Contents

```
lib/
├── base_bloc/
│   ├── base_bloc.dart        # Abstract base for all BLoCs
│   ├── base_cubit.dart       # Abstract base for all Cubits
│   ├── base_bloc_view.dart   # StatefulWidget lifecycle manager
│   ├── base_state.dart       # Base state (isLoading, isValid, errorMessage)
│   ├── lifecycle_bloc.dart   # onInit / onReady contract
│   ├── paginated_bloc.dart   # Mixin for paginated list BLoCs
│   └── active_cubit_helper.dart  # getActive / publishActive helpers
├── domain/
│   ├── base_repository.dart  # Abstract repository contract
│   └── base_use_case.dart    # Abstract use case contract
└── utils/validator/          # Fluent form validation system
```

## BaseBloc

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final MyRepository _repo;

  MyBloc(this._repo) : super(const MyState()) {
    on<MyFetched>(_onFetched);
  }

  // Called after the first frame renders — safe place for initial API calls
  @override
  void onReady() => add(const MyFetched());

  Future<void> _onFetched(MyFetched event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getItems();
    result.when(
      ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
      err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

> Dependencies (`authManager`, `apiManager`, etc.) are **not** auto-injected. Pass them via the constructor for explicit, testable code.

## BaseCubit

Use for form screens where events are overkill:

```dart
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void setEmail(String value) => safeEmit(state.copyWith(email: value));

  Future<void> login() async {
    safeEmit(state.copyWith(isLoading: true));
    final result = await getIt<AuthManager>().login(state.email, state.password);
    result.when(
      ok: (_) => safeEmit(state.copyWith(isLoading: false)),
      err: (e) => safeEmit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

> `safeEmit` skips the emit if the cubit is already closed — prevents post-dispose crashes.

## BaseBlocView

Manages bloc lifecycle (create → onInit → onReady → dispose) and shows a loading overlay automatically when `state.isLoading` is true:

```dart
BaseBlocView<MyBloc, MyState>(
  create: () => MyBloc(getIt<MyRepository>()),
  loadingOverlay: const MySpinner(), // optional, defaults to CircularProgressIndicator
  activeKey: 'detail-$itemId',       // optional, for multiple screens of the same type
  onInit: (bloc) { /* sync setup */ },
  onReady: (bloc) { /* post-frame */ },
  onDispose: (bloc) { /* cleanup */ },
  builder: (context, state, bloc) => Scaffold(
    body: Text(state.title),
  ),
);
```

## BaseState

```dart
class MyState extends BaseState {
  final List<MyItem> items;

  const MyState({
    this.items = const [],
    super.isLoading,
    super.errorMessage,
  });

  MyState copyWith({
    List<MyItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) => MyState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [...super.props, items];
}
```

## PaginatedBloc

Mixin for infinite-scroll lists:

```dart
class ItemListBloc extends BaseBloc<ItemListEvent, ItemListState>
    with PaginatedBloc<Item, ItemListEvent, ItemListState> {

  ItemListBloc() : super(const ItemListState()) {
    on<ItemListStarted>((e, emit) => handleLoadInitial(emit));
    on<ItemListLoadMore>((e, emit) => handleLoadMore(emit));
    on<ItemListRefreshed>((e, emit) => handleLoadInitial(emit));
  }

  @override
  void onReady() => add(const ItemListStarted());

  @override
  Future<(List<Item>, bool, int)> fetchPage(int offset, int size) async {
    final items = await _repo.getPage(offset: offset, size: size);
    return (items, items.length >= size, offset + items.length);
  }

  @override
  ItemListState paginatedState({
    List<Item>? items,
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
    errorMessage: clearError ? null : errorMessage,
  );
}
```

## Active Key

When multiple screens of the same bloc type are open simultaneously, use `activeKey` to distinguish them:

```dart
BaseBlocView<DetailBloc, DetailState>(
  create: () => DetailBloc(itemId),
  activeKey: 'detail-$itemId',
  builder: (context, state, bloc) => ...,
);

// Access from a sibling widget
final bloc = getActiveOrNull<DetailBloc>(key: 'detail-$itemId');
bloc?.add(SomeEvent());
```

## Validator

Fluent API for form field validation:

```dart
final emailValidator = FieldValidator<String>()
  .required()
  .email()
  .maxLength(100);

final passwordValidator = FieldValidator<String>()
  .required()
  .minLength(8)
  .pattern(RegExp(r'[A-Z]'), message: 'Needs an uppercase letter')
  .custom((v) => v != username ? null : 'Cannot match username');

TextFormField(validator: emailValidator.build())
```

**Available rules:** `required`, `email`, `minLength`, `maxLength`, `min`, `max`, `range`, `pattern`, `equals`, `custom`

## Dependencies

- `flutter_bloc`
- `equatable`
- `flutter_kit_network` (for `Result`, `ApiError` in domain layer)
