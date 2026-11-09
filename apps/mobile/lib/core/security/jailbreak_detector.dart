import 'package:flutter/services.dart';

class JailbreakDetector {
  static const _channel = MethodChannel('com.yourcompany.baseapp/security');

  static Future<bool> isDeviceCompromised() async {
    try {
      final result = await _channel.invokeMethod<bool>('isJailbroken');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
