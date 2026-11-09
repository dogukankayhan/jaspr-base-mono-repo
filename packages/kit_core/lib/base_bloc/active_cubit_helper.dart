import 'package:kit_network/core/di/locator.dart';
import 'package:kit_network/core/utils/kit_print.dart';

/// Active cubit helper functions
/// Registers/unregisters cubits with or without keys using GetIt
///
/// **When to use:** When multiple screens of the same type can be open in the navigation stack simultaneously
/// can be simultaneous (e.g. two different customer profile pages open).
/// Without key, only the last instance is accessible — overwrites previous.
///
/// **Typical usage (inside BaseBlocView):**
/// ```dart
/// BaseBlocView<ProfileCubit, ProfileState>(
///   activeKey: userId,          // unique identifier
///   create: () => ProfileCubit(userId: userId),
///   ...
/// )
/// // Access from another widget:
/// final cubit = getActive<ProfileCubit>(key: userId);
/// ```
///
/// If key is not provided, `_default_TypeName` is used — single instance assumed.

/// Track active registrations (for debug & getAllActive)
final Set<String> _activeKeys = {};

/// Publish active cubit (register it)
void publishActive<T extends Object>(T instance, {String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';

  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    // Warn in debug mode: publishing again with the same key
    assert(() {
      kitPrint(
        '[ActiveCubit] ⚠️ Override: $instanceName was already registered. '
        'Did you forget to pass activeKey for multiple instances of $T?',
      );
      return true;
    }());
    getIt.unregister<T>(instanceName: instanceName);
  }

  getIt.registerSingleton<T>(instance, instanceName: instanceName);
  _activeKeys.add(instanceName);
}

/// Unregister active cubit
void unpublishActive<T extends Object>({String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';

  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    getIt.unregister<T>(instanceName: instanceName);
  }
  _activeKeys.remove(instanceName);
}

/// Get active cubit (nullable)
T? getActiveOrNull<T extends Object>({String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';

  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    return getIt<T>(instanceName: instanceName);
  }
  return null;
}

/// Get active cubit (non-null, throws if not found)
T getActive<T extends Object>({String? key}) {
  final instance = getActiveOrNull<T>(key: key);
  if (instance == null) {
    throw ActiveCubitNotFoundException<T>(key);
  }
  return instance;
}

/// Returns all currently active cubit keys (for debug/logging)
Set<String> getAllActiveKeys() => Set.unmodifiable(_activeKeys);

/// Is there an active cubit of the specified type?
bool hasActive<T extends Object>({String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';
  return getIt.isRegistered<T>(instanceName: instanceName);
}

/// Custom exception - immediately visible in stack trace
class ActiveCubitNotFoundException<T> implements Exception {
  final String? key;
  const ActiveCubitNotFoundException(this.key);

  @override
  String toString() =>
      'ActiveCubitNotFoundException: No active $T found '
      '(key: ${key ?? "default"}). '
      'Active keys: ${_activeKeys.isEmpty ? "none" : _activeKeys.join(", ")}';
}
