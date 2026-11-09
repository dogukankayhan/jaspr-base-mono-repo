import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_core/jaspr_kit_core.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:kit_core/base_bloc/active_cubit_helper.dart';
import 'package:kit_core/base_bloc/base_cubit.dart';
import 'package:kit_core/base_bloc/base_state.dart';

class _CounterState extends BaseState {
  const _CounterState({this.count = 0, super.isLoading});
  final int count;

  @override
  List<Object?> get props => [...super.props, count];
}

class _CounterCubit extends BaseCubit<_CounterState> {
  _CounterCubit() : super(const _CounterState());

  int initCalls = 0;

  @override
  void onInit() => initCalls++;

  void increment() => safeEmit(_CounterState(count: state.count + 1));
  void startLoading() =>
      safeEmit(_CounterState(count: state.count, isLoading: true));
}

Component _view({void Function(_CounterCubit)? onCreated, String? activeKey}) =>
    BaseBlocView<_CounterCubit, _CounterState>(
      activeKey: activeKey,
      create: () {
        final cubit = _CounterCubit();
        onCreated?.call(cubit);
        return cubit;
      },
      builder: (context, state, cubit) => div([
        Component.text('Count: ${state.count}'),
        button(onClick: cubit.increment, [Component.text('+')]),
      ]),
    );

/// Hosts the view and removes it from the tree on click — a real unmount.
class _Host extends StatefulComponent {
  const _Host(this.child);
  final Component child;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool show = true;

  @override
  Component build(BuildContext context) => section([
    button(classes: 'hide', onClick: () => setState(() => show = false), [
      Component.text('hide'),
    ]),
    if (show) component.child,
  ]);
}

void main() {
  group('BaseBlocView (Jaspr)', () {
    testComponents('creates the cubit, calls onInit and renders state', (
      tester,
    ) async {
      late _CounterCubit cubit;
      tester.pumpComponent(_view(onCreated: (c) => cubit = c, activeKey: 't1'));

      expect(cubit.initCalls, 1);
      expect(find.text('Count: 0'), findsOneComponent);
    });

    testComponents('rebuilds on every emitted state', (tester) async {
      tester.pumpComponent(_view(activeKey: 't2'));

      await tester.click(find.tag('button'));
      expect(find.text('Count: 1'), findsOneComponent);

      await tester.click(find.tag('button'));
      expect(find.text('Count: 2'), findsOneComponent);
    });

    testComponents('shows the default loading overlay while isLoading', (
      tester,
    ) async {
      late _CounterCubit cubit;
      tester.pumpComponent(_view(onCreated: (c) => cubit = c, activeKey: 't3'));
      // wrapper div + page div
      expect(find.tag('div'), findsNComponents(2));

      cubit.startLoading();
      await tester.pump();
      // wrapper + page + overlay + spinner
      expect(find.tag('div'), findsNComponents(4));
    });

    testComponents(
      'publishes while mounted, unpublishes and closes on dispose',
      (tester) async {
        late _CounterCubit cubit;
        tester.pumpComponent(
          _Host(_view(onCreated: (c) => cubit = c, activeKey: 'k1')),
        );

        expect(getActive<_CounterCubit>(key: 'k1'), same(cubit));

        await tester.click(find.tag('button').first);

        expect(hasActive<_CounterCubit>(key: 'k1'), isFalse);
        expect(cubit.isClosed, isTrue);
      },
    );
  });
}
