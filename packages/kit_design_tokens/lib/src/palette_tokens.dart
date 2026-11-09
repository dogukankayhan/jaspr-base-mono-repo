/// Raw color palette as ARGB ints — the single source of truth for both the
/// Flutter theme (`flutter_kit_ui` → `Palette`) and the Jaspr web CSS
/// (`jaspr_kit_ui`). Edit colors here, never in the platform packages.
abstract final class PaletteTokens {
  static const int primary10 = 0xFFdbe2fe;
  static const int primary20 = 0xFFbfccfe;
  static const int primary30 = 0xFF92acfe;
  static const int primary40 = 0xFF5b7dfb;
  static const int primary50 = 0xFF3a55f7;
  static const int primary60 = 0xFF2433ec;
  static const int primary70 = 0xFF1c20d9;
  static const int primary80 = 0xFF1e1db0;
  static const int primary90 = 0xFF1d208b;
  static const int primary100 = 0xFF171754;

  static const int secondary10 = 0xFFcef9ff;
  static const int secondary20 = 0xFFa4f3fd;
  static const int secondary30 = 0xFF65e7fb;
  static const int secondary40 = 0xFF3ad7f2;
  static const int secondary50 = 0xFF04b5d6;
  static const int secondary60 = 0xFF068fb4;
  static const int secondary70 = 0xFF0d7391;
  static const int secondary80 = 0xFF145e76;
  static const int secondary90 = 0xFF153d64;
  static const int secondary100 = 0xFF073245;

  static const int tertiary10 = 0xFFf1e6ff;
  static const int tertiary20 = 0xFFe5d1ff;
  static const int tertiary30 = 0xFFd1aeff;
  static const int tertiary40 = 0xFFB47AFF;
  static const int tertiary50 = 0xFF9847ff;
  static const int tertiary60 = 0xFF8e3afa;
  static const int tertiary70 = 0xFF6d13dd;
  static const int tertiary80 = 0xFF5e16b3;
  static const int tertiary90 = 0xFF4e1390;
  static const int tertiary100 = 0xFF33006c;

  static const int fourth10 = 0xFFfce7ff;
  static const int fourth20 = 0xFFf8ceff;
  static const int fourth30 = 0xFFf7a7ff;
  static const int fourth40 = 0xFFf585ff;
  static const int fourth50 = 0xFFe83ef7;
  static const int fourth60 = 0xFFcf1edb;
  static const int fourth70 = 0xFFb015b6;
  static const int fourth80 = 0xFF911395;
  static const int fourth90 = 0xFF4e1390;
  static const int fourth100 = 0xFF33006c;

  static const int gray10 = 0xFFededf1;
  static const int gray20 = 0xFFd7d9e0;
  static const int gray30 = 0xFFb4b9c5;
  static const int gray40 = 0xFF8a91a6;
  static const int gray50 = 0xFF6c748b;
  static const int gray60 = 0xFF575d72;
  static const int gray70 = 0xFF474c5d;
  static const int gray80 = 0xFF3e4250;
  static const int gray90 = 0xFF363944;
  static const int gray100 = 0xFF24252d;

  static const int colorGray10 = 0xFFeaecf4;
  static const int colorGray20 = 0xFFd1d7e6;
  static const int colorGray30 = 0xFFa9b3d0;
  static const int colorGray40 = 0xFF7b8cb5;
  static const int colorGray50 = 0xFF5a6d9d;
  static const int colorGray60 = 0xFF475682;
  static const int colorGray70 = 0xFF3a466a;
  static const int colorGray80 = 0xFF333d59;
  static const int colorGray90 = 0xFF2e354c;
  static const int colorGray100 = 0xFF1f2333;

  static const int white10 = 0xFFffffff;
  static const int white20 = 0xFFefefef;
  static const int white30 = 0xFFdcdcdc;
  static const int white40 = 0xFFbdbdbd;
  static const int white50 = 0xFF7c7c7c;
  static const int white60 = 0xFF656565;
  static const int white70 = 0xFF525252;
  static const int white80 = 0xFF464646;
  static const int white90 = 0xFF3d3d3d;
  static const int white100 = 0xFF292929;

  static const Map<int, int> primary = {
    10: primary10,
    20: primary20,
    30: primary30,
    40: primary40,
    50: primary50,
    60: primary60,
    70: primary70,
    80: primary80,
    90: primary90,
    100: primary100,
  };
  static const Map<int, int> secondary = {
    10: secondary10,
    20: secondary20,
    30: secondary30,
    40: secondary40,
    50: secondary50,
    60: secondary60,
    70: secondary70,
    80: secondary80,
    90: secondary90,
    100: secondary100,
  };
  static const Map<int, int> tertiary = {
    10: tertiary10,
    20: tertiary20,
    30: tertiary30,
    40: tertiary40,
    50: tertiary50,
    60: tertiary60,
    70: tertiary70,
    80: tertiary80,
    90: tertiary90,
    100: tertiary100,
  };
  static const Map<int, int> fourth = {
    10: fourth10,
    20: fourth20,
    30: fourth30,
    40: fourth40,
    50: fourth50,
    60: fourth60,
    70: fourth70,
    80: fourth80,
    90: fourth90,
    100: fourth100,
  };
  static const Map<int, int> gray = {
    10: gray10,
    20: gray20,
    30: gray30,
    40: gray40,
    50: gray50,
    60: gray60,
    70: gray70,
    80: gray80,
    90: gray90,
    100: gray100,
  };
  static const Map<int, int> colorGray = {
    10: colorGray10,
    20: colorGray20,
    30: colorGray30,
    40: colorGray40,
    50: colorGray50,
    60: colorGray60,
    70: colorGray70,
    80: colorGray80,
    90: colorGray90,
    100: colorGray100,
  };
  static const Map<int, int> white = {
    10: white10,
    20: white20,
    30: white30,
    40: white40,
    50: white50,
    60: white60,
    70: white70,
    80: white80,
    90: white90,
    100: white100,
  };

  /// Every palette group by name — used to emit CSS variables
  /// (`--kit-<group>-<shade>`) on the web.
  static const Map<String, Map<int, int>> groups = {
    'primary': primary,
    'secondary': secondary,
    'tertiary': tertiary,
    'fourth': fourth,
    'gray': gray,
    'colorGray': colorGray,
    'white': white,
  };
}
