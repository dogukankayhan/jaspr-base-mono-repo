import 'package:flutter/services.dart';

/// Auto-formats a card number field as groups of 4 digits while the user
/// types (e.g. "4242 4242 4242 4242"). Max 16 digits.
class CardNumberInputFormatter extends TextInputFormatter {
  static const _maxDigits = 16;

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
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
