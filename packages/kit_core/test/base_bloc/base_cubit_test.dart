import 'package:kit_core/base_bloc/base_cubit.dart';
import 'package:kit_core/base_bloc/base_state.dart';
import 'package:test/test.dart';

// ─── Test doubles ────────────────────────────────────────────────────────────

class _State extends BaseState {
  const _State({super.isLoading, super.isValid, super.errorMessage});

  _State copyWith({
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool clearError = false,
  }) => _State(
    isLoading: isLoading ?? this.isLoading,
    isValid: isValid ?? this.isValid,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [isLoading, isValid, errorMessage];
}

class _Cubit extends BaseCubit<_State> {
  bool initCalled = false;
  bool readyCalled = false;

  _Cubit() : super(const _State());

  @override
  void onInit() {
    initCalled = true;
  }

  @override
  void onReady() {
    readyCalled = true;
  }

  void load() => safeEmit(state.copyWith(isLoading: true));
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _Cubit cubit;

  setUp(() => cubit = _Cubit());
  tearDown(() async => cubit.close());

  group('BaseCubit — initial state', () {
    test('starts with default BaseState', () {
      expect(cubit.state.isLoading, false);
      expect(cubit.state.isValid, false);
      expect(cubit.state.errorMessage, isNull);
    });
  });

  group('BaseCubit — lifecycle hooks', () {
    test('onInit can be overridden and called', () {
      cubit.onInit();
      expect(cubit.initCalled, true);
    });

    test('onReady can be overridden and called', () {
      cubit.onReady();
      expect(cubit.readyCalled, true);
    });

    test('onInit and onReady are not called automatically by constructor', () {
      final fresh = _Cubit();
      expect(fresh.initCalled, false);
      expect(fresh.readyCalled, false);
      fresh.close();
    });
  });

  group('BaseCubit — safeEmit', () {
    test('emits new state when cubit is open', () {
      cubit.load();
      expect(cubit.state.isLoading, true);
    });

    test('does not throw when emitting after close', () async {
      await cubit.close();
      expect(() => cubit.load(), returnsNormally);
    });

    test('state is unchanged after emitting on closed cubit', () async {
      final stateBefore = cubit.state;
      await cubit.close();
      cubit.load();
      expect(cubit.state, equals(stateBefore));
    });
  });

  group('BaseCubit — isClosed', () {
    test('isClosed is false before close', () {
      expect(cubit.isClosed, false);
    });

    test('isClosed is true after close', () async {
      await cubit.close();
      expect(cubit.isClosed, true);
    });
  });
}
