import 'package:kit_core/domain/base_use_case.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../repository/auth_repository.dart';
import '../entity/profile_entity.dart';

class MeUseCase extends BaseUseCase<Profile> {
  final AuthRepository repository;
  const MeUseCase(this.repository);
  @override
  Future<Result<Profile, ApiError>> call() => repository.me();
}
