import 'package:flutter_base_kit/features/shell/cubit/shell_cubit.dart';
import 'package:flutter_base_kit/features/shell/cubit/shell_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ShellCubit shellCubit;

  setUp(() {
    shellCubit = ShellCubit();
  });

  tearDown(() async {
    await shellCubit.close();
  });

  group('ShellCubit initial state', () {
    test('selectedIndex starts at 0', () {
      expect(shellCubit.state.selectedIndex, 0);
    });

    test('initial state equals ShellState(selectedIndex: 0)', () {
      expect(shellCubit.state, const ShellState(selectedIndex: 0));
    });
  });

  group('selectTab', () {
    test('selectTab(0) emits selectedIndex: 0', () {
      shellCubit.selectTab(0);
      expect(shellCubit.state.selectedIndex, 0);
    });

    test('selectTab(1) emits selectedIndex: 1', () {
      shellCubit.selectTab(1);
      expect(shellCubit.state.selectedIndex, 1);
    });

    test('selectTab(2) emits selectedIndex: 2', () {
      shellCubit.selectTab(2);
      expect(shellCubit.state.selectedIndex, 2);
    });

    test('selectTab(3) emits selectedIndex: 3', () {
      shellCubit.selectTab(3);
      expect(shellCubit.state.selectedIndex, 3);
    });

    test('consecutive tab changes emit correct final state', () {
      shellCubit.selectTab(2);
      shellCubit.selectTab(1);
      expect(shellCubit.state.selectedIndex, 1);
    });
  });

  group('ShellState', () {
    test('copyWith preserves selectedIndex when not provided', () {
      const state = ShellState(selectedIndex: 2);
      final copied = state.copyWith();
      expect(copied.selectedIndex, 2);
    });

    test('copyWith updates selectedIndex', () {
      const state = ShellState(selectedIndex: 0);
      final updated = state.copyWith(selectedIndex: 3);
      expect(updated.selectedIndex, 3);
    });

    test('props includes selectedIndex', () {
      const state = ShellState(selectedIndex: 1);
      expect(state.props, contains(1));
    });
  });
}
