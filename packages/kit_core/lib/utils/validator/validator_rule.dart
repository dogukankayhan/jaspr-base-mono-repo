/// A single validation rule for a value of type [T].
///
/// Each rule is a pure function: given a value, returns an error message
/// or null if valid.
///
/// i18n: Pass a custom [message] to override the default English message.
/// ```dart
/// Validators.required(message: t.validation.required)
/// ```
abstract class Validator<T> {
  final String? _customMessage;

  const Validator([this._customMessage]);

  /// Returns an error message if [value] fails validation, null if valid.
  String? validate(T? value);

  /// Uses custom message if provided, otherwise falls back to [defaultMessage].
  String resolveMessage(String defaultMessage) =>
      _customMessage ?? defaultMessage;
}
