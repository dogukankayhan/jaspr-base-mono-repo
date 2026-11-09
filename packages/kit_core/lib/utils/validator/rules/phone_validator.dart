import '../validator_rule.dart';

/// Validates a national phone number against the shape its country expects.
///
/// [digits] is how many digits the country's mask holds (10 for Türkiye's
/// `### ### ## ##`, see `CountryPhone.digitCount`), and [mobilePrefixes] the
/// leading digits a mobile line has to start with (`['5']` for Türkiye). An
/// empty list means any leading digit is accepted.
///
/// Accepts formatted or raw input; separators are stripped before checking.
/// An empty value passes — pair this with `Validators.required()` separately.
class PhoneValidator extends Validator<String> {
  const PhoneValidator({
    required this.digits,
    this.mobilePrefixes = const [],
    String? message,
  }) : super(message);

  final int digits;
  final List<String> mobilePrefixes;

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != digits) {
      return resolveMessage('Geçerli bir telefon numarası giriniz');
    }
    if (mobilePrefixes.isNotEmpty &&
        !mobilePrefixes.any(digitsOnly.startsWith)) {
      return resolveMessage('Geçerli bir cep telefonu numarası giriniz');
    }
    return null;
  }
}
