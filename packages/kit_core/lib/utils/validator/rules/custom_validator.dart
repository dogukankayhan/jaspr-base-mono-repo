import '../validator_rule.dart';

/// Custom validation with a lambda function.
///
/// ```dart
/// Validators.custom<String>((value) {
///   if (value != null && value.contains(' ')) return 'No spaces allowed';
///   return null;
/// })
/// ```
class CustomValidator<T> extends Validator<T> {
  final String? Function(T? value) _validateFn;

  const CustomValidator(this._validateFn);

  @override
  String? validate(T? value) => _validateFn(value);
}
