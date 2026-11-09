import 'dart:async';

/// Web implementation — see `run_in_background.dart`.
Future<T> runInBackground<T>(FutureOr<T> Function() computation) async =>
    computation();
