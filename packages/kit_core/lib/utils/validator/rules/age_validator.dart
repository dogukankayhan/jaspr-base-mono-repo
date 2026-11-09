import '../validator_rule.dart';

/// Non-blocking age warning: returns a message when the parsed integer < [minAge].
/// Returns null for empty or non-numeric values — those are handled upstream
/// by RequiredValidator or PatternValidator.
class AgeValidator extends Validator<String> {
  final int minAge;

  const AgeValidator({this.minAge = 18, String? message}) : super(message);

  @override
  String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final age = int.tryParse(value.trim());
    if (age == null) return null;
    if (age < minAge) {
      return resolveMessage(
        '$minAge yaşından küçükler için bazı özellikler kısıtlı olabilir',
      );
    }
    return null;
  }
}
