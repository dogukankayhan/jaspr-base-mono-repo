/// Lays [digits] into a `#`-slot [pattern], stopping as soon as the digits run
/// out so no trailing separator is left dangling.
///
/// ```dart
/// maskPhoneDigits('5551234567', '### ### ## ##'); // 555 123 45 67
/// maskPhoneDigits('5551234567', '(###) ###-####'); // (555) 123-4567
/// maskPhoneDigits('555', '### ### ## ##'); // 555   — not '555 '
/// ```
String maskPhoneDigits(String digits, String pattern) {
  final buffer = StringBuffer();
  var index = 0;
  for (final char in pattern.split('')) {
    if (index >= digits.length) break;
    if (char == '#') {
      buffer.write(digits[index]);
      index++;
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}
