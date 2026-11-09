import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class GuestSignInUseCase {
  final AuthRepository repository;
  const GuestSignInUseCase(this.repository);

  Future<Result<AuthTokens, ApiError>> call() => repository.guestSignIn();
}
