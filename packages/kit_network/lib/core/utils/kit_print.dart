/// Platform-neutral debug logger used across the kit packages.
///
/// Replaces Flutter's `debugPrint` so these packages can compile without the
/// Flutter SDK (e.g. inside the Jaspr web app). Apps can redirect output —
/// the Flutter app may point it at `debugPrint` for throttled console output:
///
/// ```dart
/// kitPrinter = (message) => debugPrint(message);
/// ```
void Function(String message) kitPrinter = _defaultPrinter;

void _defaultPrinter(String message) {
  // ignore: avoid_print
  print(message);
}

/// Logs [message] through [kitPrinter].
void kitPrint(String message) => kitPrinter(message);
