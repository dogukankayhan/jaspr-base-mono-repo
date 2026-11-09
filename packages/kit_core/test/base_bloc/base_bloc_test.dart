import 'package:bloc/bloc.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
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

sealed class _Event {}

class _Load extends _Event {}

class _Fail extends _Event {}

class _TestBloc extends BaseBloc<_Event, _State> {
  bool initCalled = false;
  bool readyCalled = false;

  _TestBloc() : super(const _State()) {
    on<_Load>(_onLoad);
    on<_Fail>(_onFail);
  }

  @override
  void onInit() => initCalled = true;

  @override
  void onReady() => readyCalled = true;

  Future<void> _onLoad(_Load event, Emitter<_State> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    emit(state.copyWith(isLoading: false, isValid: true));
  }

  Future<void> _onFail(_Fail event, Emitter<_State> emit) async {
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(isLoading: false, errorMessage: 'error'));
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _TestBloc bloc;

  setUp(() => bloc = _TestBloc());
  tearDown(() async => bloc.close());

  group('BaseBloc — initial state', () {
    test('starts with default BaseState', () {
      expect(bloc.state.isLoading, false);
      expect(bloc.state.isValid, false);
      expect(bloc.state.errorMessage, isNull);
    });
  });

  group('BaseBloc — lifecycle hooks', () {
    test('onInit can be overridden and called', () {
      bloc.onInit();
      expect(bloc.initCalled, true);
    });

    test('onReady can be overridden and called', () {
      bloc.onReady();
      expect(bloc.readyCalled, true);
    });

    test('hooks are not called automatically by constructor', () {
      final fresh = _TestBloc();
      expect(fresh.initCalled, false);
      expect(fresh.readyCalled, false);
      fresh.close();
    });
  });

  group('BaseBloc — event handling', () {
    test('_Load event sets isValid: true and clears loading', () async {
      bloc.add(_Load());
      await Future.delayed(Duration.zero);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.isValid, true);
    });

    test('_Load event clears previous errorMessage', () async {
      bloc.add(_Fail());
      await Future.delayed(Duration.zero);
      expect(bloc.state.errorMessage, 'error');

      bloc.add(_Load());
      await Future.delayed(Duration.zero);
      expect(bloc.state.errorMessage, isNull);
    });

    test('_Fail event sets errorMessage and clears loading', () async {
      bloc.add(_Fail());
      await Future.delayed(Duration.zero);
      expect(bloc.state.errorMessage, 'error');
      expect(bloc.state.isLoading, false);
    });
  });

  group('BaseBloc — isClosed', () {
    test('isClosed is false before close', () => expect(bloc.isClosed, false));

    test('isClosed is true after close', () async {
      await bloc.close();
      expect(bloc.isClosed, true);
    });
  });
}
