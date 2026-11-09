import '../validator_rule.dart';

/// Checks that a string matches a given regex pattern.
class PatternValidator extends Validator<String> {
  final RegExp _regex;

  PatternValidator(String pattern, [super.message]) : _regex = RegExp(pattern);

  PatternValidator.regex(this._regex, [super.message]);

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_regex.hasMatch(value)) {
      return resolveMessage('Invalid format');
    }
    return null;
  }
}
