import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);
  Future<Result<AuthTokens, ApiError>> call(RegisterRequest request) =>
      repository.register(request);
}
