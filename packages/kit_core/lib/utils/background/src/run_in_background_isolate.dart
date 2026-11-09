import 'dart:async';
import 'dart:isolate';

/// VM implementation — see `run_in_background.dart`.
Future<T> runInBackground<T>(FutureOr<T> Function() computation) =>
    Isolate.run(computation);
