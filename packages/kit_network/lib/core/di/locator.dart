import 'package:get_it/get_it.dart';

/// The single GetIt instance shared by every package and app in the workspace.
///
/// Lives in pure Dart so both the Flutter app (via `flutter_kit_network`'s
/// `service_locator.dart`, which re-exports it) and the Jaspr web app resolve
/// from the same container.
final GetIt getIt = GetIt.instance;
