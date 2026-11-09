import 'package:dio/dio.dart';
import 'package:kit_core/domain/base_repository.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import '../entity/auth_entity.dart';
import '../entity/password_reset_entity.dart';
import '../entity/profile_entity.dart';

abstract class AuthRepository implements BaseRepository {
  Future<Result<AuthTokens, ApiError>> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> register(
    RegisterRequest request, {
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> refresh({
    required String refreshToken,
    CancelToken? cancelToken,
  });
  Future<Result<Profile, ApiError>> me({CancelToken? cancelToken});
  Future<Result<Profile, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  });
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken});

  // Social auth
  Future<Result<AuthTokens, ApiError>> socialSignIn(
    SocialSignInRequest request, {
    CancelToken? cancelToken,
  });
  Future<Result<AuthTokens, ApiError>> guestSignIn({CancelToken? cancelToken});

  // Password reset — see CLAUDE.md Rule 3; a generic skeleton, extend as needed.
  Future<Result<void, ApiError>> startPasswordReset(
    PasswordResetStartRequest request, {
    CancelToken? cancelToken,
  });
  Future<Result<void, ApiError>> verifyPasswordReset(
    PasswordResetVerifyRequest request, {
    CancelToken? cancelToken,
  });
  Future<Result<void, ApiError>> completePasswordReset(
    PasswordResetCompleteRequest request, {
    CancelToken? cancelToken,
  });
}
