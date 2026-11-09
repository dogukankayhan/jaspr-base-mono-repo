import '../validator_rule.dart';

/// Checks that a string has at least [minLength] characters.
class MinLengthValidator extends Validator<String> {
  final int minLength;

  const MinLengthValidator(this.minLength, [super.message]);

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < minLength) {
      return resolveMessage('Must be at least $minLength characters');
    }
    return null;
  }
}
