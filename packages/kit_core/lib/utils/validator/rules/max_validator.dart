import '../validator_rule.dart';

/// Checks that a number is at most [max].
class MaxValidator extends Validator<num> {
  final num max;

  const MaxValidator(this.max, [super.message]);

  @override
  String? validate(num? value) {
    if (value == null) return null;
    if (value > max) {
      return resolveMessage('Must be at most $max');
    }
    return null;
  }
}
