import '../validator_rule.dart';

/// Checks that a string has at most [maxLength] characters.
class MaxLengthValidator extends Validator<String> {
  final int maxLength;

  const MaxLengthValidator(this.maxLength, [super.message]);

  @override
  String? validate(String? value) {
    if (value == null) return null;
    if (value.length > maxLength) {
      return resolveMessage('Must be at most $maxLength characters');
    }
    return null;
  }
}
