import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/localization/i18n/strings.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import 'package:flutter_kit_ui/theme/app_theme.dart';
import 'package:flutter_kit_ui/theme/theme_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'core/config/app_environment.dart';
import 'core/deeplink/deep_link_manager.dart';
import 'core/di/injection.dart';
import 'core/initialize/initialize.dart';

Future<void> mainCommon(AppEnvironment env, {bool removeSplash = false}) async {
  await Initialize.prepare(env);
  if (removeSplash) FlutterNativeSplash.remove();

  runApp(
    RequestsInspector(
      enabled: kDebugMode,
      showInspectorOn: ShowInspectorOn.Both,
      child: TranslationProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: Initialize.themeCubit),
            BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = getIt<GoRouter>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkManager.instance.attach(_router);
    });
  }

  @override
  void dispose() {
    DeepLinkManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Builder(
          builder: (ctx) {
            final flutterLocale = TranslationProvider.of(ctx).flutterLocale;

            return ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: !AppConfig.instance.isProd,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: flutterLocale,
                  supportedLocales: AppLocaleUtils.supportedLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: _router,
                );
              },
            );
          },
        );
      },
    );
  }
}
