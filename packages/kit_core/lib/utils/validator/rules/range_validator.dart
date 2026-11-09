import '../validator_rule.dart';

/// Checks that a number is between [min] and [max] (inclusive).
class RangeValidator extends Validator<num> {
  final num min;
  final num max;

  const RangeValidator(this.min, this.max, [super.message]);

  @override
  String? validate(num? value) {
    if (value == null) return null;
    if (value < min || value > max) {
      return resolveMessage('Must be between $min and $max');
    }
    return null;
  }
}
