import 'package:url_launcher/url_launcher_string.dart';

/// Hands off to other apps on the device via URL schemes (mail, phone, SMS,
/// WhatsApp, browser).
abstract final class AppLauncher {
  /// Opens the mail app with [to] pre-filled, and optionally [subject]/[body].
  static Future<bool> openEmail({
    required String to,
    String? subject,
    String? body,
  }) {
    final query = _buildQuery({'subject': subject, 'body': body});
    return _launch('mailto:$to${query.isEmpty ? '' : '?$query'}');
  }

  /// Opens the phone dialer with [phoneNumber] pre-filled.
  static Future<bool> openPhone(String phoneNumber) =>
      _launch('tel:${Uri.encodeComponent(phoneNumber)}');

  /// Opens the SMS app addressed to [phoneNumber], optionally with [message].
  static Future<bool> openSms(String phoneNumber, {String? message}) {
    final query = (message == null || message.isEmpty)
        ? ''
        : '?body=${Uri.encodeComponent(message)}';
    return _launch('sms:${Uri.encodeComponent(phoneNumber)}$query');
  }

  /// Opens a WhatsApp chat pre-filled with [message], optionally to
  /// [phoneNumber] (international format, digits only, e.g. `905551234567`).
  static Future<bool> openWhatsApp({String? phoneNumber, String? message}) {
    final params = _buildQuery({
      'phone': phoneNumber,
      'text': message,
    });
    return _launch('https://wa.me/?$params');
  }

  /// Opens [url] in the browser / external app associated with it.
  static Future<bool> openWebsite(String url) => _launch(url);

  static String _buildQuery(Map<String, String?> params) {
    final entries = params.entries.where(
      (e) => e.value != null && e.value!.isNotEmpty,
    );
    return entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value!)}').join('&');
  }

  static Future<bool> _launch(String url) async {
    try {
      return await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
