import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../repository/auth_repository.dart';
import '../entity/profile_entity.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;
  const UpdateProfileUseCase(this.repository);
  Future<Result<Profile, ApiError>> call(Map<String, dynamic> patch) =>
      repository.updateProfile(patch);
}
