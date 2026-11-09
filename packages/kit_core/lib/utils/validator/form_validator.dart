/// Validates multiple fields and tracks overall form validity.
///
/// Each field is defined as lazy function — reads current state value when called
/// reads the current state value.
///
/// ```dart
/// FormValidator get _form => FormValidator({
///   'email': () => emailValidator.validate(state.email),
///   'password': () => passwordValidator.validate(state.password),
/// });
///
/// bool isValid = _form.isValid;
/// Map<String, String?> errors = _form.errors;
/// String? emailError = _form.errorFor('email');
/// ```
class FormValidator {
  final Map<String, String? Function()> _fields;

  const FormValidator(this._fields);

  /// True if every field passes validation.
  bool get isValid {
    for (final validate in _fields.values) {
      if (validate() != null) return false;
    }
    return true;
  }

  /// Map of field name → error message (null if that field is valid).
  Map<String, String?> get errors =>
      _fields.map((key, validate) => MapEntry(key, validate()));

  /// Only fields that have errors.
  Map<String, String> get activeErrors {
    final result = <String, String>{};
    for (final entry in _fields.entries) {
      final error = entry.value();
      if (error != null) result[entry.key] = error;
    }
    return result;
  }

  /// Error for a specific field, or null if valid.
  String? errorFor(String fieldName) => _fields[fieldName]?.call();
}
