import '../validator_rule.dart';

/// Checks that a number is at least [min].
class MinValidator extends Validator<num> {
  final num min;

  const MinValidator(this.min, [super.message]);

  @override
  String? validate(num? value) {
    if (value == null) return null;
    if (value < min) {
      return resolveMessage('Must be at least $min');
    }
    return null;
  }
}
