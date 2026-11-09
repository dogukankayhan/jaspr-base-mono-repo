/// Runs [computation] off the main isolate where the platform supports it.
///
/// * Dart VM / Flutter (mobile): `Isolate.run` — heavy JSON → entity mapping
///   doesn't jank the UI thread.
/// * Web (dart2js / wasm): there is no `dart:isolate`, so it runs inline.
///
/// Use this instead of importing `dart:isolate` in shared (pure) packages —
/// a direct import silently drops the whole web entrypoint from compilation.
library;

export 'src/run_in_background_inline.dart'
    if (dart.library.isolate) 'src/run_in_background_isolate.dart';
