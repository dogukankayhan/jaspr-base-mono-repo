import 'package:flutter/services.dart';

import '../extensions/string_ext.dart';

/// Title-cases a person's name as it is typed — see [StringExt.titleCaseTr].
///
/// Length-preserving, so the caret stays where it was and a trailing space is
/// never swallowed mid-word.
class NameCaseInputFormatter extends TextInputFormatter {
  const NameCaseInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.titleCaseTr);
}
