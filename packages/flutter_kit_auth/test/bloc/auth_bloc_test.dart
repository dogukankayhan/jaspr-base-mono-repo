import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import 'package:flutter_kit_auth/auth/bloc/auth_event.dart';
import 'package:flutter_kit_auth/auth/bloc/auth_state.dart';
import 'package:flutter_kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:flutter_kit_auth/auth/domain/entity/profile_entity.dart';
import 'package:flutter_kit_auth/auth/manager/auth_manager.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../manager/auth_manager_test.mocks.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockMeUseCase mockMe;
  late MockUpdateProfileUseCase mockUpdateProfile;
  late MockLogoutUseCase mockLogout;
  late MockRefreshUseCase mockRefresh;
  late MockSocialSignInUseCase mockSocial;
  late MockGuestSignInUseCase mockGuest;
  late MockStartPasswordResetUseCase mockStartPasswordReset;
  late MockVerifyPasswordResetUseCase mockVerifyPasswordReset;
  late MockCompletePasswordResetUseCase mockCompletePasswordReset;
  late MockTokenStore mockTokenStore;

  final tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  final profile = Profile(id: '1', email: 'user@test.com', firstName: 'Test');

  Future<AuthManager> buildManager({AuthTokens? storedTokens}) async {
    when(mockTokenStore.read()).thenAnswer((_) async => storedTokens);
    if (storedTokens != null) {
      when(mockMe()).thenAnswer((_) async => Ok(profile));
    }
    return AuthManager.create(
      loginUseCase: mockLogin,
      registerUseCase: mockRegister,
      meUseCase: mockMe,
      updateProfileUseCase: mockUpdateProfile,
      logoutUseCase: mockLogout,
      refreshUseCase: mockRefresh,
      socialSignInUseCase: mockSocial,
      guestSignInUseCase: mockGuest,
      startPasswordResetUseCase: mockStartPasswordReset,
      verifyPasswordResetUseCase: mockVerifyPasswordReset,
      completePasswordResetUseCase: mockCompletePasswordReset,
      tokenStore: mockTokenStore,
    );
  }

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockMe = MockMeUseCase();
    mockUpdateProfile = MockUpdateProfileUseCase();
    mockLogout = MockLogoutUseCase();
    mockRefresh = MockRefreshUseCase();
    mockSocial = MockSocialSignInUseCase();
    mockGuest = MockGuestSignInUseCase();
    mockStartPasswordReset = MockStartPasswordResetUseCase();
    mockVerifyPasswordReset = MockVerifyPasswordResetUseCase();
    mockCompletePasswordReset = MockCompletePasswordResetUseCase();
    mockTokenStore = MockTokenStore();

    provideDummy<Result<AuthTokens, ApiError>>(
      Ok(AuthTokens(accessToken: '', refreshToken: null)),
    );
    provideDummy<Result<Profile, ApiError>>(Ok(Profile(id: '')));
    provideDummy<Result<void, ApiError>>(const Ok(null));
    provideDummy<Result<AuthTokens?, ApiError>>(const Ok(null));
  });

  group('AuthBloc initial state', () {
    test('starts unauthenticated when no session', () async {
      final auth = await buildManager();
      final bloc = AuthBloc(auth);

      expect(bloc.state.isAuthenticated, false);
      expect(bloc.state.profile, null);
      expect(bloc.state.isLoading, false);

      await bloc.close();
    });

    test('starts authenticated when session restored', () async {
      final auth = await buildManager(storedTokens: tokens);
      final bloc = AuthBloc(auth);

      // AuthManager notifies listeners after create() — give bloc time to react
      await Future.delayed(Duration.zero);

      expect(bloc.state.isAuthenticated, true);
      expect(bloc.state.profile, profile);

      await bloc.close();
    });
  });

  group('AuthStatusChanged', () {
    test('reflects AuthManager state after login', () async {
      final auth = await buildManager();
      final bloc = AuthBloc(auth);

      when(mockLogin(any)).thenAnswer((_) async => Ok(tokens));
      when(mockMe()).thenAnswer((_) async => Ok(profile));
      when(mockTokenStore.write(tokens)).thenAnswer((_) async {});

      await auth.login('a@b.com', 'pass');
      await Future.delayed(Duration.zero);

      expect(bloc.state.isAuthenticated, true);
      expect(bloc.state.profile, profile);

      await bloc.close();
    });

    test('reflects AuthManager state after logout', () async {
      final auth = await buildManager(storedTokens: tokens);
      final bloc = AuthBloc(auth);

      when(mockLogout()).thenAnswer((_) async => const Ok(null));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      await auth.logout();

      // Wait for the BLoC event stream to fully process AuthStatusChanged
      await expectLater(
        bloc.stream.firstWhere((s) => !s.isAuthenticated),
        completes,
      );

      expect(bloc.state.isAuthenticated, false);
      expect(bloc.state.profile, null);

      await bloc.close();
    });
  });

  group('AuthLogoutRequested', () {
    test('triggers logout via event', () async {
      final auth = await buildManager(storedTokens: tokens);
      final bloc = AuthBloc(auth);

      when(mockLogout()).thenAnswer((_) async => const Ok(null));
      when(mockTokenStore.clear()).thenAnswer((_) async {});

      bloc.add(const AuthLogoutRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.isAuthenticated, false);

      await bloc.close();
    });
  });

  group('AuthState', () {
    test('copyWith preserves unchanged fields', () {
      const state = AuthState(isAuthenticated: true, isLoading: false);
      final updated = state.copyWith(isLoading: true);

      expect(updated.isAuthenticated, true);
      expect(updated.isLoading, true);
    });

    test('props includes isAuthenticated and profile', () {
      final state = AuthState(isAuthenticated: true, profile: profile);
      expect(state.props, contains(true));
      expect(state.props, contains(profile));
    });

    test('initial state is unauthenticated and not loading', () {
      const state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.profile, null);
    });
  });

  group('Listener cleanup', () {
    test('closed bloc does not emit when AuthManager notifies', () async {
      final auth = await buildManager();
      final bloc = AuthBloc(auth);
      await bloc.close();

      // After close, stream events from AuthManager must not throw or cause errors
      // (subscription was cancelled — if it wasn't, this would throw on closed bloc)
      expect(() => auth.saveTokens(null), returnsNormally);
    });
  });
}
