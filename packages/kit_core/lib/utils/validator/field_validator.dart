import 'validation_result.dart';
import 'validator_rule.dart';

/// Composes multiple [Validator] rules for a single field.
///
/// ```dart
/// final emailValidator = FieldValidator<String>([
///   Validators.required(),
///   Validators.email(),
/// ]);
///
/// String? error = emailValidator.validate(state.email);
/// ValidationResult all = emailValidator.validateAll(state.email);
/// ```
class FieldValidator<T> {
  final List<Validator<T>> _rules;

  const FieldValidator(this._rules);

  /// Returns the first error message, or null if valid.
  String? validate(T? value) {
    for (final rule in _rules) {
      final error = rule.validate(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Returns a [ValidationResult] containing ALL error messages.
  ValidationResult validateAll(T? value) {
    final errors = <String>[];
    for (final rule in _rules) {
      final error = rule.validate(value);
      if (error != null) errors.add(error);
    }
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Returns true if the value passes all rules.
  bool isValid(T? value) => validate(value) == null;

  /// Creates a new FieldValidator with additional rules appended.
  FieldValidator<T> and(List<Validator<T>> additionalRules) =>
      FieldValidator<T>([..._rules, ...additionalRules]);
}
