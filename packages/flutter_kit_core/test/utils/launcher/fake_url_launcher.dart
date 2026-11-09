import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Test double for [UrlLauncherPlatform] that records the last launched URL
/// instead of hitting a real platform channel.
class FakeUrlLauncher extends UrlLauncherPlatform {
  String? lastUrl;
  bool canLaunchResult = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => canLaunchResult;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    lastUrl = url;
    return true;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastUrl = url;
    return true;
  }
}
