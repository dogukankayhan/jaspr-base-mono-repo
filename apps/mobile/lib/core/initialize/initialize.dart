import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_base_kit/core/firebase/firebase_options_dev.dart'
    as dev;
import 'package:flutter_base_kit/core/firebase/firebase_options_prod.dart'
    as prod;
import 'package:flutter_base_kit/core/firebase/firebase_options_staging.dart'
    as staging;
import 'package:flutter_base_kit/core/localization/i18n/strings.g.dart';
import 'package:flutter_kit_firebase/firebase_setup.dart';
import 'package:flutter_kit_network/core/config/environment_config.dart';
import 'package:flutter_kit_ui/theme/theme_cubit.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../config/app_environment.dart';
import '../di/injection.dart';
import '../security/jailbreak_detector.dart';

class Initialize {
  Initialize._();

  static late ThemeCubit themeCubit;
  static bool isDeviceCompromised = false;

  static const bool _firebaseEnabled = false;
  static const bool _jailbreakEnabled = false;

  static Future<void> prepare(AppEnvironment env) async {
    await _initBinding();
    _initErrorHandlers();
    await Future.wait([_initOrientation(), AppConfig.init(env)]);
    if (_firebaseEnabled) await _initFirebase(env);
    await _initDI(env);
    await _initLocaleAndTheme();
  }

  /// Called on splash screen — heavy work done here.
  static Future<void> run() async {
    if (_firebaseEnabled) await _initNotifications();
    if (_jailbreakEnabled) isDeviceCompromised = await _checkJailbreak();
  }

  // ─────────────────────────────────────────────
  // Private init steps
  // ─────────────────────────────────────────────

  static Future<WidgetsBinding> _initBinding() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);
    return binding;
  }

  static void _initErrorHandlers() {
    // Flutter framework errors (widget build, layout, etc.)
    FlutterError.onError = (details) {
      FlutterError.presentError(details); // debug console'a yazar
      // if (_firebaseEnabled) FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Dart async errors and non-Flutter platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[FATAL] $error\n$stack');
      // if (_firebaseEnabled) FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true; // true → we handled the error, do not crash the platform
    };
  }

  static Future<void> _initOrientation() =>
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

  static Future<void> _initFirebase(AppEnvironment env) async {
    final options = switch (env) {
      AppEnvironment.dev => dev.DefaultFirebaseOptions.currentPlatform,
      AppEnvironment.staging => staging.DefaultFirebaseOptions.currentPlatform,
      AppEnvironment.prod => prod.DefaultFirebaseOptions.currentPlatform,
    };
    await setupFirebase(options: options);
  }

  static Future<void> _initDI(AppEnvironment env) async {
    final config = switch (env) {
      AppEnvironment.dev => EnvironmentConfig.development(
        baseUrl: AppConfig.instance.baseUrl,
      ),
      AppEnvironment.staging => EnvironmentConfig.staging(
        baseUrl: AppConfig.instance.baseUrl,
      ),
      AppEnvironment.prod => EnvironmentConfig.production(
        baseUrl: AppConfig.instance.baseUrl,
      ),
    };
    await Injection.init(config: config);
  }

  static Future<void> _initLocaleAndTheme() async {
    LocaleSettings.useDeviceLocale();
    themeCubit = ThemeCubit();
    await themeCubit.loadSavedTheme();
  }

  static Future<void> _initNotifications() => setupNotifications();

  static Future<bool> _checkJailbreak() =>
      JailbreakDetector.isDeviceCompromised();
}
