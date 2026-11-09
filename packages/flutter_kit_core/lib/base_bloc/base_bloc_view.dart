import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'active_cubit_helper.dart';
import 'lifecycle_bloc.dart';
import 'base_state.dart';

/// Base Bloc View - all bloc/cubit views should use this widget
///
/// Features:
/// - Manages Bloc/Cubit lifecycle (onInit, onReady, close)
/// - Distinguishes multiple screens of the same type using active key
/// - provides onInit, onReady, onDispose callbacks
/// - Publishes/unpublishes blocs/cubits with GetIt
/// - Supports both BaseBloc and BaseCubit
///
final class BaseBlocView<C extends LifecycleBloc, S extends BaseState>
    extends StatefulWidget {
  /// Builder that draws screen content
  /// [bloc] parameter added - now you can access the bloc directly inside builder
  final Widget Function(BuildContext context, S state, C bloc) builder;

  /// Function that creates Bloc/Cubit
  final C Function() create;

  /// Optional active key to distinguish multiple screens of the same type.
  /// E.g. storyId for StoryDetail, conversationId for Chat...
  final String? activeKey;

  /// Bloc/Cubit lifecycle callbacks
  final Function(C)? onInit;
  final Function(C)? onReady;
  final Function(C)? onDispose;

  /// do you want post-frame call after build? (default: true)
  final bool? usePostFrame;

  /// widget to be shown when state.isLoading is true.
  /// If not specified, default CircularProgressIndicator is used.
  final Widget? loadingOverlay;

  const BaseBlocView({
    super.key,
    required this.builder,
    required this.create,
    this.activeKey,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.usePostFrame,
    this.loadingOverlay,
  });

  @override
  State<BaseBlocView<C, S>> createState() => _BaseBlocViewState<C, S>();
}

final class _BaseBlocViewState<C extends LifecycleBloc, S extends BaseState>
    extends State<BaseBlocView<C, S>>
    with WidgetsBindingObserver {
  late final C bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1) Create Bloc/Cubit specifically for the screen
    bloc = widget.create();

    // 2) Publish as active bloc (with key or default)
    publishActive<C>(bloc, key: widget.activeKey);

    // 3) onInit callback
    bloc.onInit();
    widget.onInit?.call(bloc);

    // 4) onReady: bloc.onReady() + view callback are triggered together.
    // BaseBlocView handles central lifecycle control here.
    final usePostFrame = widget.usePostFrame ?? true;
    if (usePostFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !bloc.isClosed) {
          bloc.onReady();
          widget.onReady?.call(bloc);
        }
      });
    } else {
      bloc.onReady();
      widget.onReady?.call(bloc);
    }
  }

  @override
  void dispose() {
    // dispose callback
    widget.onDispose?.call(bloc);

    // 5) Unpublish active bloc when screen is closed (with key or default)
    unpublishActive<C>(key: widget.activeKey);

    WidgetsBinding.instance.removeObserver(this);

    // Close the Bloc/Cubit
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cast to StateStreamableSource for BlocProvider/BlocBuilder
    final stateStreamable = bloc as StateStreamableSource<S>;

    return BlocProvider<StateStreamableSource<S>>.value(
      value: stateStreamable,
      child: BlocBuilder<StateStreamableSource<S>, S>(
        builder: (context, state) {
          return Stack(
            children: [
              widget.builder(context, state, bloc),
              if (state.isLoading)
                widget.loadingOverlay ??
                    ColoredBox(
                      color: Colors.black26,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
