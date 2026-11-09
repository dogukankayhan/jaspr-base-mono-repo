import '../validator_rule.dart';

/// Checks that a value is not null, not empty string, not empty iterable.
class RequiredValidator<T> extends Validator<T> {
  const RequiredValidator([super.message]);

  @override
  String? validate(T? value) {
    if (value == null) return resolveMessage('This field is required');
    if (value is String && value.trim().isEmpty) {
      return resolveMessage('This field is required');
    }
    if (value is Iterable && value.isEmpty) {
      return resolveMessage('This field is required');
    }
    return null;
  }
}
