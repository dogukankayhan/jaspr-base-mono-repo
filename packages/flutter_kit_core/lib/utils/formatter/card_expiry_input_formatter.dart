import 'package:flutter/services.dart';

/// Auto-formats a card expiry field as MM/YY while the user types.
/// Max 4 digits (MMYY); a `/` is inserted after position 2.
class CardExpiryInputFormatter extends TextInputFormatter {
  static const _maxDigits = 4;

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
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
