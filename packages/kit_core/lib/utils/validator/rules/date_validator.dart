import '../validator_rule.dart';

/// Validates a date string in DD.MM.YYYY format.
/// Checks format match, valid month range (1–12), and calendar validity
/// using DateTime normalization detection.
class DateValidator extends Validator<String> {
  const DateValidator([super.message]);

  static final _regex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_regex.hasMatch(value)) {
      return resolveMessage('Geçerli bir tarih giriniz (GG.AA.YYYY)');
    }
    final parts = value.split('.');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    if (month < 1 || month > 12) {
      return resolveMessage('Ay 1–12 arasında olmalıdır');
    }

    // DateTime normalizes invalid dates; detect by comparing fields back.
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return resolveMessage('Geçersiz tarih');
    }
    return null;
  }
}
