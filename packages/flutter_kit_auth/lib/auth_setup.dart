import 'package:flutter_kit_auth/auth/service/social_auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:kit_auth/auth/manager/auth_manager.dart';
import 'package:kit_auth/auth/token/token_store.dart';
import 'package:kit_auth/auth_core_setup.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';

/// Dependency Injection setup for the Auth package (Flutter app).
/// `apiManager` and `tokenStore` are provided externally.
///
/// The platform-neutral part (AuthManager + AuthBloc) lives in
/// `kit_auth`'s [setupAuthCore] so the web app shares it; this adds the
/// Flutter-only social sign-in service on top.
///
/// [fcmTokenProvider] is optional — pass it only once the app layer has
/// wired up `flutter_kit_firebase`; see [FcmTokenProvider].
///
/// [googleServerClientId] is optional — pass it (from the app's own OAuth
/// client config, never hardcoded here) to register [SocialAuthService] for
/// Google/Apple sign-in. Left null, no social sign-in UI is available and the
/// registration is skipped.
///
/// [refreshApiManager] should be an [ApiManager] instance with no
/// auth/refresh interceptors attached, used only for the refresh-token call
/// — see `AuthRepositoryImpl.refreshApi`. Left null, [apiManager] is reused,
/// which is fine as long as nothing wires that instance's refresh flow back
/// through this same call.
Future<void> setupAuth({
  required GetIt getIt,
  required ApiManager apiManager,
  required TokenStore tokenStore,
  FcmTokenProvider? fcmTokenProvider,
  String? googleServerClientId,
  ApiManager? refreshApiManager,
}) async {
  await setupAuthCore(
    getIt: getIt,
    apiManager: apiManager,
    tokenStore: tokenStore,
    fcmTokenProvider: fcmTokenProvider,
    refreshApiManager: refreshApiManager,
  );

  // Holds Google's initialize-once flag → single shared instance.
  if (googleServerClientId != null) {
    getIt.registerLazySingleton<SocialAuthService>(
      () => SocialAuthService(googleServerClientId: googleServerClientId),
    );
  }
}
