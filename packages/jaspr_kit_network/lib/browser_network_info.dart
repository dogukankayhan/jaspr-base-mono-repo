import 'dart:async';

import 'package:kit_network/core/network/connectivity/network_info.dart';
import 'package:web/web.dart' as web;

export 'package:kit_network/core/network/connectivity/network_info.dart';

/// [NetworkInfo] backed by the browser's `navigator.onLine` and the
/// `online` / `offline` window events. Web twin of flutter_kit_network's
/// connectivity_plus-based `NetworkInfoImpl`.
///
/// Note: `navigator.onLine == true` only means "has a network interface"; a
/// failing request is still the source of truth (as on mobile).
class BrowserNetworkInfo implements NetworkInfo {
  const BrowserNetworkInfo();

  @override
  Future<bool> get isConnected async => web.window.navigator.onLine;

  @override
  Stream<bool> get onConnectivityChanged => _merge(
    web.EventStreamProviders.onlineEvent.forTarget(web.window).map((_) => true),
    web.EventStreamProviders.offlineEvent
        .forTarget(web.window)
        .map((_) => false),
  );

  static Stream<bool> _merge(Stream<bool> a, Stream<bool> b) {
    late final StreamController<bool> controller;
    StreamSubscription<bool>? subA;
    StreamSubscription<bool>? subB;
    controller = StreamController<bool>.broadcast(
      onListen: () {
        subA = a.listen(controller.add);
        subB = b.listen(controller.add);
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
      },
    );
    return controller.stream;
  }
}
