import 'package:flutter/services.dart';

/// Auto-formats a date field as DD.MM.YYYY while the user types.
///
/// - Only digit characters are kept; dots are stripped from pasted input
///   and re-inserted automatically.
/// - Max 8 digits (DDMMYYYY).
/// - Dots are inserted after position 2 and 4 in the digit stream.
///
/// Example: paste "23.07.1985" → strip dots → "23071985" → "23.07.1985" ✓
class DateInputFormatter extends TextInputFormatter {
  static const _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length > _maxDigits) digits = digits.substring(0, _maxDigits);

    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buf.write('.');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
