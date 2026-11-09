enum SocialAuthProvider { apple, google, guest }

extension SocialAuthProviderX on SocialAuthProvider {
  String get key => switch (this) {
    SocialAuthProvider.apple => 'apple',
    SocialAuthProvider.google => 'google',
    SocialAuthProvider.guest => 'guest',
  };
}
