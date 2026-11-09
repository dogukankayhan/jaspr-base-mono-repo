import 'package:kit_core/base_bloc/base_state.dart';
import 'package:test/test.dart';

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

void main() {
  group('BaseState — defaults', () {
    const state = _State();

    test('isLoading defaults to false', () => expect(state.isLoading, false));
    test('isValid defaults to false', () => expect(state.isValid, false));
    test(
      'errorMessage defaults to null',
      () => expect(state.errorMessage, isNull),
    );
  });

  group('BaseState — copyWith', () {
    test('updates isLoading', () {
      const s = _State();
      expect(s.copyWith(isLoading: true).isLoading, true);
    });

    test('updates isValid', () {
      const s = _State();
      expect(s.copyWith(isValid: true).isValid, true);
    });

    test('updates errorMessage', () {
      const s = _State();
      expect(s.copyWith(errorMessage: 'oops').errorMessage, 'oops');
    });

    test('preserves unchanged fields', () {
      const s = _State(isLoading: true, isValid: true, errorMessage: 'err');
      final updated = s.copyWith(isLoading: false);
      expect(updated.isLoading, false);
      expect(updated.isValid, true);
      expect(updated.errorMessage, 'err');
    });

    test('clearError sets errorMessage to null regardless of new value', () {
      const s = _State(errorMessage: 'old error');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('clearError wins over errorMessage passed together', () {
      const s = _State(errorMessage: 'old');
      final result = s.copyWith(errorMessage: 'new', clearError: true);
      expect(result.errorMessage, isNull);
    });
  });

  group('BaseState — Equatable', () {
    test('equal states are equal', () {
      const a = _State(isLoading: true, errorMessage: 'x');
      const b = _State(isLoading: true, errorMessage: 'x');
      expect(a, equals(b));
    });

    test('different states are not equal', () {
      const a = _State(isLoading: true);
      const b = _State(isLoading: false);
      expect(a, isNot(equals(b)));
    });

    test('props includes all three fields', () {
      const s = _State(isLoading: true, isValid: true, errorMessage: 'e');
      expect(s.props, [true, true, 'e']);
    });
  });
}
