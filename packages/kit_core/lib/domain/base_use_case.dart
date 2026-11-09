import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

/// Base class for parameterless use cases.
///
/// ```dart
/// class MeUseCase extends BaseUseCase<Profile> {
///   @override
///   Future<Result<Profile, ApiError>> call() => repository.me();
/// }
/// ```
abstract class BaseUseCase<Output> {
  const BaseUseCase();
  Future<Result<Output, ApiError>> call();
}

/// Base class for parameterized use cases.
///
/// ```dart
/// class LoginUseCase extends BaseParamsUseCase<LoginParams, AuthTokens> {
///   @override
///   Future<Result<AuthTokens, ApiError>> call(LoginParams params) => ...
/// }
/// ```
abstract class BaseParamsUseCase<Params, Output> {
  const BaseParamsUseCase();
  Future<Result<Output, ApiError>> call(Params params);
}
