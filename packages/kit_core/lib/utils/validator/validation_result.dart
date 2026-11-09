/// Result of validating a single field with multiple rules.
class ValidationResult {
  final List<String> errors;

  /// Field passed all validations.
  const ValidationResult.valid() : errors = const [];

  /// Field has one or more errors.
  const ValidationResult.invalid(this.errors);

  /// True if the field passed all validations.
  bool get isValid => errors.isEmpty;

  /// First error message, or null if valid.
  String? get firstError => errors.isEmpty ? null : errors.first;
}
