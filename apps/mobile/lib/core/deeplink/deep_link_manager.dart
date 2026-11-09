import 'dart:async';
import 'dart:io' show Platform;
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Handles runtime (warm/hot) app links safely.
/// Cold start is handled by GoRouter; use getInitialAppLink below if you want to force it.
final class DeepLinkManager {
  DeepLinkManager._();
  static final DeepLinkManager instance = DeepLinkManager._();

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _attached = false;

  void attach(GoRouter router) {
    if (_attached) return;
    _attached = true;

    final supported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
    if (!supported) {
      debugPrint('[DeepLink] unsupported platform');
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        _appLinks = AppLinks();
        _sub = _appLinks!.uriLinkStream.listen(
          (uri) {
            // Navigate next frame to avoid setState-during-build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              router.go(uri.toString());
            });
          },
          onError: (e) {
            debugPrint('[DeepLink] stream error: $e');
          },
        );
        debugPrint('[DeepLink] attached');
      } catch (e) {
        debugPrint('[DeepLink] attach failed: $e');
      }
    });
  }

  /// Optional: handle cold-start deep link explicitly (GoRouter usually handles it).
  Future<void> handleInitialIfAny(GoRouter router) async {
    try {
      final uri = await _appLinks?.getInitialLink();
      if (uri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go(uri.toString());
        });
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _appLinks = null;
    _attached = false;
  }
}
