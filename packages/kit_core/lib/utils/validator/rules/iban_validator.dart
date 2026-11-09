import '../validator_rule.dart';

/// Validates a Turkish IBAN.
/// Accepts formatted form with spaces or raw string.
/// After stripping spaces: must match ^TR\d{24}$ (26 chars total).
class IbanValidator extends Validator<String> {
  const IbanValidator([super.message]);

  static final _regex = RegExp(r'^TR\d{24}$');

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    final raw = value.replaceAll(' ', '');
    if (!_regex.hasMatch(raw)) {
      return resolveMessage('Geçerli bir IBAN giriniz (TR + 24 rakam)');
    }
    return null;
  }
}
