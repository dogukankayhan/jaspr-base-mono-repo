import 'package:flutter/widgets.dart';
import 'i18n/strings.g.dart';

extension TranslationX on BuildContext {
  Translations get translations => TranslationProvider.of(this).translations;
}
