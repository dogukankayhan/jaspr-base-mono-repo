import '../validator_rule.dart';

/// Checks that a string is a valid email address.
class EmailValidator extends Validator<String> {
  static final _regex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  const EmailValidator([super.message]);

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_regex.hasMatch(value)) {
      return resolveMessage('Invalid email address');
    }
    return null;
  }
}
