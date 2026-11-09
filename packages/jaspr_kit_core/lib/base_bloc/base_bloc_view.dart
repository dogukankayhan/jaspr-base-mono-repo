import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:kit_core/base_bloc/active_cubit_helper.dart';
import 'package:kit_core/base_bloc/base_state.dart';
import 'package:kit_core/base_bloc/lifecycle_bloc.dart';

/// Jaspr counterpart of `flutter_kit_core`'s `BaseBlocView` widget.
///
/// Same contract, same lifecycle — so a bloc/cubit from `app_shared` drives a
/// web page exactly the way it drives a mobile screen:
///
/// ```
/// initState  → create() → publishActive() → onInit()
/// post-frame → onReady()            (client only — see below)
/// dispose    → unpublishActive() → close()
/// ```
///
/// ```dart
/// BaseBlocView<DetailBloc, DetailState>(
///   create: () => DetailBloc.create(),
///   onReady: (bloc) => bloc.add(DetailLoad(id)),
///   builder: (context, state, bloc) => div([...]),
/// )
/// ```
///
/// **SSR note:** `onReady` (where screens start loading data) only runs in the
/// browser. In `server`/`static` mode the server renders the initial state and
/// the client hydrates and loads — this keeps per-request data out of the
/// shared server process. In `client` mode (the default for apps/web) this
/// distinction does not matter.
final class BaseBlocView<C extends LifecycleBloc, S extends BaseState>
    extends StatefulComponent {
  const BaseBlocView({
    required this.create,
    required this.builder,
    this.activeKey,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.loading,
    this.showLoadingOverlay = true,
    super.key,
  });

  /// Builds the page from the current state. [bloc] is passed for dispatch.
  final Component Function(BuildContext context, S state, C bloc) builder;

  /// Creates the Bloc/Cubit — typically `XxxBloc.create` (see CLAUDE.md Rule 3).
  final C Function() create;

  /// Distinguishes several live instances of the same bloc type
  /// (see `getActive<T>(key:)` in kit_core's active_cubit_helper).
  final String? activeKey;

  final void Function(C bloc)? onInit;
  final void Function(C bloc)? onReady;
  final void Function(C bloc)? onDispose;

  /// Rendered on top of the page while `state.isLoading` is true.
  /// Defaults to a `div.kit-loading-overlay` (styled by jaspr_kit_ui).
  final Component? loading;

  /// Set false when the page renders its own loading states (skeletons,
  /// "loading more…" rows) — e.g. paginated lists.
  final bool showLoadingOverlay;

  /// The wrapper element every BaseBlocView renders.
  ///
  /// A real element with `display: contents` (no layout box) instead of a
  /// `Component.fragment`: jaspr 0.23.1 asserts when a page whose root is a
  /// fragment is removed on navigation ("Non-empty attached fragments must
  /// have a valid last child reference"), which in debug mode aborts the
  /// rebuild — the URL changes on browser Back but the old page stays.
  ///
  /// Public for server rendering: a `@client` component that renders its
  /// first state on the server *without* a bloc wraps it in [shell], so the
  /// HTML matches what the client's BaseBlocView produces on hydration.
  static Component shell(List<Component> children) =>
      div(classes: 'kit-bloc-view', styles: _wrapperStyles, children);

  static const _wrapperStyles = Styles(raw: {'display': 'contents'});

  @override
  State<BaseBlocView<C, S>> createState() => _BaseBlocViewState<C, S>();
}

final class _BaseBlocViewState<C extends LifecycleBloc, S extends BaseState>
    extends State<BaseBlocView<C, S>> {
  late final C bloc;
  late S _state;
  StreamSubscription<S>? _subscription;

  /// Every BaseBloc/BaseCubit is a BlocBase — LifecycleBloc only adds hooks.
  BlocBase<S> get _source => bloc as BlocBase<S>;

  @override
  void initState() {
    super.initState();

    // 1) Create the screen's own Bloc/Cubit
    bloc = component.create();
    _state = _source.state;

    // 2) Publish as active bloc (with key or default)
    publishActive<C>(bloc, key: component.activeKey);

    // 3) onInit
    bloc.onInit();
    component.onInit?.call(bloc);

    // Rebuild on every state change
    _subscription = _source.stream.listen((next) {
      if (!mounted) return;
      setState(() => _state = next);
    });

    // 4) onReady after the first frame — browser only (see class docs)
    if (kIsWeb) {
      context.binding.addPostFrameCallback(() {
        if (mounted && !bloc.isClosed) {
          bloc.onReady();
          component.onReady?.call(bloc);
        }
      });
    }
  }

  @override
  void dispose() {
    component.onDispose?.call(bloc);
    _subscription?.cancel();

    // 5) Unpublish and close
    unpublishActive<C>(key: component.activeKey);
    bloc.close();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return BaseBlocView.shell([
      component.builder(context, _state, bloc),
      if (_state.isLoading && component.showLoadingOverlay)
        component.loading ??
            div(classes: 'kit-loading-overlay', [
              div(classes: 'kit-spinner', []),
            ]),
    ]);
  }
}
