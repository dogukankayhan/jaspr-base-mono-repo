import '../validator_rule.dart';

/// Checks that a value equals another (live) value.
///
/// [compareValue] is a getter so it can reference live state:
/// ```dart
/// Validators.equals(() => state.password)
/// ```
class EqualsValidator<T> extends Validator<T> {
  final T Function() _compareValueFn;

  const EqualsValidator(this._compareValueFn, [super.message]);

  @override
  String? validate(T? value) {
    if (value == null) return null;
    if (value != _compareValueFn()) {
      return resolveMessage('Values do not match');
    }
    return null;
  }
}
