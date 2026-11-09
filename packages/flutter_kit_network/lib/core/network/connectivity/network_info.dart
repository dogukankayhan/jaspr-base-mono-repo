import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kit_network/core/network/connectivity/network_info.dart';

export 'package:kit_network/core/network/connectivity/network_info.dart';

/// connectivity_plus-backed [NetworkInfo] for the Flutter app.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((result) {
      return !result.contains(ConnectivityResult.none);
    });
  }
}
