import 'package:flutter/material.dart';
import 'package:flutter_kit_firebase/notification/notification_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/shell_navigator.dart';
import '../initialize/initialize.dart';
import '../managers/navigation_manager/app_navigator.dart';
import '../security/jailbreak_block_app.dart';
import 'splash_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      Initialize.run(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    if (Initialize.isDeviceCompromised) {
      runApp(const JailbreakBlockApp());
      return;
    }

    final token = await NotificationManager.instance.getToken();
    debugPrint('FCM TOKEN: $token');

    if (!mounted) return;

    rootKey.currentContext?.go(ShellNavigator.pokemonPath);
  }

  @override
  Widget build(BuildContext context) => const SplashView();
}
