/// Connectivity abstraction.
///
/// Pure Dart on purpose: platform implementations live with the platform —
/// `NetworkInfoImpl` (connectivity_plus) in `flutter_kit_network`, and the
/// browser's `navigator.onLine` in the web app.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Fallback that always reports "online". Useful for tests, server-side code,
/// or any platform where connectivity cannot be observed.
class AlwaysOnlineNetworkInfo implements NetworkInfo {
  const AlwaysOnlineNetworkInfo();

  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}
