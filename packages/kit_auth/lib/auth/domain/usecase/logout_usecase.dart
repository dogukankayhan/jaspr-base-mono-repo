import 'package:kit_core/domain/base_use_case.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../repository/auth_repository.dart';

class LogoutUseCase extends BaseUseCase<void> {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);
  @override
  Future<Result<void, ApiError>> call() => repository.logout();
}
