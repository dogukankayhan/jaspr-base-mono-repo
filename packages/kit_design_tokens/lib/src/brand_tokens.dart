/// Semantic brand colors as ARGB ints. `flutter_kit_ui`'s `AppBrandColors`
/// and the web CSS both read from here.
abstract final class BrandTokens {
  static const int primary = 0xFF5b7dfb; // primary[40]
  static const int primaryBusy = 0xFF3a55f7; // primary[50]
  static const int primaryContainer = 0xFFdbe2fe; // primary[10]
  static const int onPrimaryContainer = 0xFF171754; // primary[100]
  static const int inversePrimary = 0xFF92acfe; // primary[30]
  static const int secondaryPalette = 0xFF3ad7f2; // secondary[40]
  static const int secondaryContainer = 0xFFcef9ff; // secondary[10]
  static const int onSecondaryContainer = 0xFF073245; // secondary[100]
  static const int tertiary = 0xFFB47AFF; // tertiary[40]
  static const int tertiaryContainer = 0xFFf1e6ff; // tertiary[10]
  static const int onTertiaryContainer = 0xFF33006c; // tertiary[100]
  static const int onPrimary = 0xFFFFFFFF;
  static const int onSecondary = 0xFF24262d;
  static const int onError = 0xFFFF6F69;
  static const int error = 0xFFFF5160;
  static const int helper = 0xFFF20505;
  static const int success = 0xFF00B69B;
  static const int warn = 0xFFFC9058;
  static const int info = 0xFFEBF7EC;
  static const int primaryLight = 0xFF9FE2F1;
  static const int successLight = 0xFFD8E3BE;
  static const int gold = 0xFFF7B519;
  static const int goldLight = 0xFFFFCC5C;
  static const int ceil = 0xFF969EC9;
  static const int textBlack = 0xFF12141C;
  static const int blueShadow = 0xFF194F5B;
  static const int grayBase = 0xFF979797;
  static const int grayDark = 0xFF383A40;
  static const int grayLight = 0xFFD8D8D8;
  static const int shadowGreen = 0xFF9DC2BA;
  static const int tanHide = 0xFFFC905B;
  static const int goldenTainoi = 0xFFFFCC5C;
  static const int secondaryTitleColor = 0xFF5a6d9d; // colorGray[50]
  static const int selectedTabIconColor = 0xFF5b7dfb; // primary[40]
  static const int unSelectedTabIconColor = 0xFF6c748b; // gray[50]

  /// Every brand color by name — used to emit CSS variables
  /// (`--kit-<name>`) on the web.
  static const Map<String, int> all = {
    'primary': primary,
    'primaryBusy': primaryBusy,
    'primaryContainer': primaryContainer,
    'onPrimaryContainer': onPrimaryContainer,
    'inversePrimary': inversePrimary,
    'secondaryPalette': secondaryPalette,
    'secondaryContainer': secondaryContainer,
    'onSecondaryContainer': onSecondaryContainer,
    'tertiary': tertiary,
    'tertiaryContainer': tertiaryContainer,
    'onTertiaryContainer': onTertiaryContainer,
    'onPrimary': onPrimary,
    'onSecondary': onSecondary,
    'onError': onError,
    'error': error,
    'helper': helper,
    'success': success,
    'warn': warn,
    'info': info,
    'primaryLight': primaryLight,
    'successLight': successLight,
    'gold': gold,
    'goldLight': goldLight,
    'ceil': ceil,
    'textBlack': textBlack,
    'blueShadow': blueShadow,
    'grayBase': grayBase,
    'grayDark': grayDark,
    'grayLight': grayLight,
    'shadowGreen': shadowGreen,
    'tanHide': tanHide,
    'goldenTainoi': goldenTainoi,
    'secondaryTitleColor': secondaryTitleColor,
    'selectedTabIconColor': selectedTabIconColor,
    'unSelectedTabIconColor': unSelectedTabIconColor,
  };
}
