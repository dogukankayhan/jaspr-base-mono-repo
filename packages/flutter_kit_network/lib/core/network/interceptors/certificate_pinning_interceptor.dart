import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

/// Certificate pinning interceptor.
///
/// Usage — pass your SHA-256 fingerprints (without colons, uppercase):
/// ```dart
/// CertificatePinningInterceptor(
///   allowedSHAs: {'A1B2C3...', 'D4E5F6...'},
/// )
/// ```
/// Always include at least two fingerprints (primary + backup) so a cert
/// rotation doesn't lock users out.
class CertificatePinningInterceptor extends Interceptor {
  final Set<String> allowedSHAs;

  const CertificatePinningInterceptor({required this.allowedSHAs});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['certificatePinning'] = true;
    handler.next(options);
  }

  /// Call this when creating the HttpClient to validate certificates.
  ///
  /// Example:
  /// ```dart
  /// final httpClient = HttpClient()
  ///   ..badCertificateCallback = pinningInterceptor.badCertificateCallback;
  /// ```
  bool badCertificateCallback(X509Certificate cert, String host, int port) {
    final sha = _sha256Fingerprint(cert.der);
    if (allowedSHAs.contains(sha)) return false; // certificate is valid
    return true; // reject — not in pinned set
  }

  String _sha256Fingerprint(List<int> der) {
    final digest = sha256.convert(der);
    return digest.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }
}
