import 'package:get_it/get_it.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';

import 'auth/bloc/auth_bloc.dart';
import 'auth/data/repository/auth_repository_impl.dart';
import 'auth/domain/usecase/guest_sign_in_usecase.dart';
import 'auth/domain/usecase/login_usecase.dart';
import 'auth/domain/usecase/logout_usecase.dart';
import 'auth/domain/usecase/me_usecase.dart';
import 'auth/domain/usecase/password_reset_usecase.dart';
import 'auth/domain/usecase/refresh_usecase.dart';
import 'auth/domain/usecase/register_usecase.dart';
import 'auth/domain/usecase/social_sign_in_usecase.dart';
import 'auth/domain/usecase/update_profile_usecase.dart';
import 'auth/manager/auth_manager.dart';
import 'auth/token/token_store.dart';

/// Platform-neutral auth wiring: registers [AuthManager] and [AuthBloc].
///
/// Shared by both apps — `flutter_kit_auth`'s `setupAuth()` calls this and then
/// adds the Flutter-only pieces (Google/Apple sign-in); the Jaspr web app calls
/// it directly with a browser [TokenStore].
///
/// [refreshApiManager] should be an [ApiManager] with no auth/refresh
/// interceptors attached — see [AuthRepositoryImpl.refreshApi].
Future<void> setupAuthCore({
  required GetIt getIt,
  required ApiManager apiManager,
  required TokenStore tokenStore,
  FcmTokenProvider? fcmTokenProvider,
  ApiManager? refreshApiManager,
}) async {
  // Stateless pass-through repository — built once here, not registered in
  // GetIt (see CLAUDE.md DI rules).
  final authRepository = AuthRepositoryImpl(
    apiManager,
    refreshApi: refreshApiManager,
  );

  final authManager = await AuthManager.create(
    loginUseCase: LoginUseCase(authRepository),
    registerUseCase: RegisterUseCase(authRepository),
    meUseCase: MeUseCase(authRepository),
    updateProfileUseCase: UpdateProfileUseCase(authRepository),
    logoutUseCase: LogoutUseCase(authRepository),
    refreshUseCase: RefreshUseCase(authRepository),
    socialSignInUseCase: SocialSignInUseCase(authRepository),
    guestSignInUseCase: GuestSignInUseCase(authRepository),
    startPasswordResetUseCase: StartPasswordResetUseCase(authRepository),
    verifyPasswordResetUseCase: VerifyPasswordResetUseCase(authRepository),
    completePasswordResetUseCase: CompletePasswordResetUseCase(authRepository),
    tokenStore: tokenStore,
    fcmTokenProvider: fcmTokenProvider,
  );
  getIt.registerSingleton<AuthManager>(authManager);
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthManager>()));
}
