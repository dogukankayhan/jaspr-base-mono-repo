import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../entity/password_reset_entity.dart';
import '../repository/auth_repository.dart';

class StartPasswordResetUseCase {
  final AuthRepository repository;
  const StartPasswordResetUseCase(this.repository);
  Future<Result<void, ApiError>> call(PasswordResetStartRequest request) =>
      repository.startPasswordReset(request);
}

class VerifyPasswordResetUseCase {
  final AuthRepository repository;
  const VerifyPasswordResetUseCase(this.repository);
  Future<Result<void, ApiError>> call(PasswordResetVerifyRequest request) =>
      repository.verifyPasswordReset(request);
}

class CompletePasswordResetUseCase {
  final AuthRepository repository;
  const CompletePasswordResetUseCase(this.repository);
  Future<Result<void, ApiError>> call(PasswordResetCompleteRequest request) =>
      repository.completePasswordReset(request);
}
