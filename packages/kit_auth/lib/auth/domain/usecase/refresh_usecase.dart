import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../repository/auth_repository.dart';
import '../entity/auth_entity.dart';

class RefreshUseCase {
  final AuthRepository repository;
  const RefreshUseCase(this.repository);
  Future<Result<AuthTokens, ApiError>> call(String refreshToken) =>
      repository.refresh(refreshToken: refreshToken);
}
