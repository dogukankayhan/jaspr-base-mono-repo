import 'package:flutter/services.dart';

/// Formats a Turkish IBAN (TR + 24 digits) as the user types.
///
/// Rules:
///   - "TR" prefix is always present; it cannot be deleted.
///   - Only digits are accepted after "TR".
///   - Max 24 digits after "TR".
///   - Display: "TR" + digits grouped in blocks of 4 separated by spaces.
///     E.g. "TR33 0006 1005 1978 6457 8417" (26 raw chars, 31 displayed).
///
/// Paste handling:
///   - Paste with "TR" prefix (any case): strip it, extract digits, reformat.
///   - Paste digits only: prepend "TR", reformat.
///   - Paste formatted IBAN (with spaces): spaces are stripped automatically.
///
/// The controller must be initialised with "TR" before first render so that
/// the formatter's invariant is met from the start.
class IbanInputFormatter extends TextInputFormatter {
  static const _prefix = 'TR';
  static const _maxDigits = 24;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;

    String digits;
    if (raw.toUpperCase().startsWith('TR')) {
      digits = raw.substring(2).replaceAll(RegExp(r'[^\d]'), '');
    } else {
      digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    }

    if (digits.length > _maxDigits) digits = digits.substring(0, _maxDigits);

    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Groups the combined "TR" + digits string in blocks of 4.
  String _format(String digits) {
    final combined = '$_prefix$digits';
    final buf = StringBuffer();
    for (var i = 0; i < combined.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(combined[i]);
    }
    return buf.toString();
  }
}
