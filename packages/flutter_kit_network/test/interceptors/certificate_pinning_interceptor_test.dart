import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/certificate_pinning_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('CertificatePinningInterceptor Tests', () {
    test('adds certificatePinning: true to request options extra', () async {
      const interceptor = CertificatePinningInterceptor(
        allowedSHAs: {'AABBCC'},
      );
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.completer.future;

      expect(options.extra['certificatePinning'], true);
      expect(handler.nextOptions, isNotNull);
    });

    test(
      'badCertificateCallback returns false (valid) if fingerprint is allowed',
      () {
        const interceptor = CertificatePinningInterceptor(
          allowedSHAs: {
            'FA22DFE1DA9013B3C1145040ACAE9089E0C08BC1C1A0719614F4B73ADD6F6EF5',
          },
        );
        final mockCert = MockX509Certificate([0xAA, 0xBB, 0xCC]);

        final result = interceptor.badCertificateCallback(
          mockCert,
          'host',
          443,
        );

        expect(result, isFalse);
      },
    );

    test(
      'badCertificateCallback returns true (invalid) if fingerprint is not allowed',
      () {
        const interceptor = CertificatePinningInterceptor(
          allowedSHAs: {'DDEEFF'},
        );
        final mockCert = MockX509Certificate([0xAA, 0xBB, 0xCC]);

        final result = interceptor.badCertificateCallback(
          mockCert,
          'host',
          443,
        );

        expect(result, isTrue);
      },
    );
  });
}
