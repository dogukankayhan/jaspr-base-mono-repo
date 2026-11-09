import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import '../entity/user_profile.dart';

abstract interface class UserRepository {
  Future<Result<UserProfile, ApiError>> getProfile();
}
