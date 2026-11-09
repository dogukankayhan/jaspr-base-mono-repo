import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import '../entity/user_profile.dart';
import '../repository/user_repository.dart';

class GetUserProfileUseCase {
  GetUserProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<Result<UserProfile, ApiError>> call() => _repository.getProfile();
}
