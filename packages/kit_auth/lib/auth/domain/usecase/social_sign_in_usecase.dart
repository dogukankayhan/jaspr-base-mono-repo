import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

/// Single provider-driven use case — replaces one class per provider (Apple,
/// Google, ...); [SocialAuthProvider] picks the branch instead.
class SocialSignInUseCase {
  final AuthRepository repository;
  const SocialSignInUseCase(this.repository);
  Future<Result<AuthTokens, ApiError>> call(SocialSignInRequest request) =>
      repository.socialSignIn(request);
}
