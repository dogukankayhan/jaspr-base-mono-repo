/// Converts an ARGB int token (`0xAARRGGBB`) to a CSS color string.
///
/// Opaque colors become `#rrggbb`; translucent ones `#rrggbbaa`.
String cssHex(int argb) {
  final a = (argb >> 24) & 0xFF;
  final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return a == 0xFF ? '#$rgb' : '#$rgb${a.toRadixString(16).padLeft(2, '0')}';
}
