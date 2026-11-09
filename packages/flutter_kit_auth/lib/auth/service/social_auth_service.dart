import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/enum/social_auth_provider.dart';

/// Everything the platform sheet handed back, ready to exchange for a
/// session via [SocialSignInUseCase].
class SocialCredential {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.firstName,
    this.lastName,
    this.email,
  });

  final SocialAuthProvider provider;
  final String idToken;

  /// Null whenever the provider withheld them — Apple does so on every
  /// authorization after the first, which is not an error: the backend keeps
  /// what it stored the first time.
  final String? firstName;
  final String? lastName;
  final String? email;
}

/// Opens the platform's own sign-in sheet and hands back what it returned.
///
/// A null return means the user backed out — an ordinary outcome, not a
/// failure, so callers should clear their loading flag without showing an
/// error. Anything that genuinely went wrong throws instead.
///
/// Nothing here touches the API: pass the resulting [SocialCredential] to
/// `SocialSignInUseCase` to exchange it for a session.
class SocialAuthService {
  SocialAuthService({required this.googleServerClientId});

  final String googleServerClientId;
  bool _googleInitialized = false;

  /// Apple ships the native sheet on its own platforms only. On Android the
  /// plugin falls back to a browser flow needing a Services ID and a redirect
  /// endpoint most apps don't run, so hide the button there rather than
  /// opening something that cannot complete.
  static bool get isAppleSupported => Platform.isIOS || Platform.isMacOS;

  Future<SocialCredential?> credential(SocialAuthProvider provider) =>
      provider == SocialAuthProvider.apple ? _apple() : _google();

  Future<SocialCredential?> _google() async {
    // GoogleSignIn.instance must be initialized exactly once before any
    // other call — safe to repeat the guard since this service is a
    // long-lived singleton.
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: googleServerClientId,
      );
      _googleInitialized = true;
    }

    try {
      // authenticate() is always interactive — unlike
      // attemptLightweightAuthentication(), it never silently reuses a
      // cached session, so there's no need to sign out first.
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return null;

      final (first, last) = _splitDisplayName(account.displayName);
      return SocialCredential(
        provider: SocialAuthProvider.google,
        idToken: idToken,
        firstName: first,
        lastName: last,
        email: account.email,
      );
    } on GoogleSignInException catch (e) {
      // Dismissing the sheet arrives here as an exception; everything else is
      // a real failure and keeps travelling.
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<SocialCredential?> _apple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = credential.identityToken;
      if (idToken == null) return null;

      return SocialCredential(
        provider: SocialAuthProvider.apple,
        idToken: idToken,
        firstName: credential.givenName,
        lastName: credential.familyName,
        email: credential.email,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  /// Google exposes one display name where the request wants two fields. The
  /// **last** word is taken as the family name and everything before it as
  /// the given name: two given names are common and two family names are
  /// not, so splitting from the end keeps the surname intact.
  /// "Ahmet Mehmet Yılmaz" → ("Ahmet Mehmet", "Yılmaz").
  (String?, String?) _splitDisplayName(String? displayName) {
    final parts = displayName?.trim().split(RegExp(r'\s+')) ?? const [];
    if (parts.isEmpty || parts.first.isEmpty) return (null, null);
    if (parts.length == 1) return (parts.first, null);
    return (parts.sublist(0, parts.length - 1).join(' '), parts.last);
  }
}
