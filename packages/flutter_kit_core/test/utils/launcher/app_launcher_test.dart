import 'package:flutter_kit_core/utils/launcher/app_launcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'fake_url_launcher.dart';

void main() {
  late FakeUrlLauncher fake;

  setUp(() {
    fake = FakeUrlLauncher();
    UrlLauncherPlatform.instance = fake;
  });

  group('openEmail', () {
    test('builds a mailto URL with no extras', () async {
      await AppLauncher.openEmail(to: 'a@b.com');
      expect(fake.lastUrl, 'mailto:a@b.com');
    });

    test('includes subject and body when provided', () async {
      await AppLauncher.openEmail(
        to: 'a@b.com',
        subject: 'Hello there',
        body: 'How are you?',
      );
      expect(
        fake.lastUrl,
        'mailto:a@b.com?subject=Hello%20there&body=How%20are%20you%3F',
      );
    });
  });

  test('openPhone builds a tel URL', () async {
    await AppLauncher.openPhone('+905551234567');
    expect(fake.lastUrl, 'tel:%2B905551234567');
  });

  group('openSms', () {
    test('builds an sms URL with no body', () async {
      await AppLauncher.openSms('+905551234567');
      expect(fake.lastUrl, 'sms:%2B905551234567');
    });

    test('includes the message as the body', () async {
      await AppLauncher.openSms('+905551234567', message: 'hi there');
      expect(fake.lastUrl, 'sms:%2B905551234567?body=hi%20there');
    });
  });

  group('openWhatsApp', () {
    test('builds a wa.me URL with phone and text', () async {
      await AppLauncher.openWhatsApp(phoneNumber: '905551234567', message: 'hi');
      expect(fake.lastUrl, 'https://wa.me/?phone=905551234567&text=hi');
    });

    test('omits missing parameters', () async {
      await AppLauncher.openWhatsApp(message: 'hi');
      expect(fake.lastUrl, 'https://wa.me/?text=hi');
    });
  });

  test('openWebsite launches the URL as-is', () async {
    await AppLauncher.openWebsite('https://example.com');
    expect(fake.lastUrl, 'https://example.com');
  });

  test('returns false instead of throwing when launch fails', () async {
    fake.canLaunchResult = false;
    final result = await AppLauncher.openPhone('123');
    expect(result, isA<bool>());
  });
}
