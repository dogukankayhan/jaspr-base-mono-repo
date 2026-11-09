import 'package:dio/dio.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/network/error/api_exception.dart';
import 'package:kit_network/core/utils/result.dart';

import '../../domain/entity/auth_entity.dart';
import '../../domain/entity/password_reset_entity.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../api/guest_sign_in_endpoint.dart';
import '../api/login_endpoint.dart';
import '../api/logout_endpoint.dart';
import '../api/me_endpoint.dart';
import '../api/password_reset_endpoint.dart';
import '../api/refresh_endpoint.dart';
import '../api/register_endpoint.dart';
import '../api/social_sign_in_endpoint.dart';
import '../api/update_profile_endpoint.dart';
import '../dto/login_request_dto.dart';
import '../dto/password_reset_request_dto.dart';
import '../dto/profile_dto.dart';
import '../dto/refresh_request_dto.dart';
import '../dto/register_request_dto.dart';
import '../dto/social_sign_in_request_dto.dart';
import '../dto/tokens_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiManager api;

  /// Used only by [refresh]. Must never carry the auth/refresh interceptors
  /// that sit on [api] — the refresh call is what those interceptors wait
  /// on, so routing it back through them (e.g. an expired refresh token
  /// also coming back 401) would re-enter their lock and hang. Defaults to
  /// [api] so callers that don't have a dedicated instance still work.
  final ApiManager refreshApi;

  AuthRepositoryImpl(this.api, {ApiManager? refreshApi})
    : refreshApi = refreshApi ?? api;

  @override
  Future<Result<AuthTokens, ApiError>> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: LoginEndpoint.path,
        body: LoginEndpoint.body(LoginRequestDto.fromEntity(request)),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<AuthTokens, ApiError>> register(
    RegisterRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: RegisterEndpoint.path,
        body: RegisterEndpoint.body(RegisterRequestDto.fromEntity(request)),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<AuthTokens, ApiError>> refresh({
    required String refreshToken,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await refreshApi.post<Map<String, dynamic>>(
        path: RefreshEndpoint.path,
        body: RefreshEndpoint.body(
          RefreshRequestDto(refreshToken: refreshToken),
        ),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<Profile, ApiError>> me({CancelToken? cancelToken}) async {
    try {
      final response = await api.get<Map<String, dynamic>>(
        path: MeEndpoint.path,
        cancelToken: cancelToken,
      );
      return Ok(ProfileDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<Profile, ApiError>> updateProfile(
    Map<String, dynamic> patch, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.patch<Map<String, dynamic>>(
        path: UpdateProfileEndpoint.path,
        body: UpdateProfileEndpoint.body(patch),
        cancelToken: cancelToken,
      );
      return Ok(ProfileDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<void, ApiError>> logout({CancelToken? cancelToken}) async {
    try {
      await api.post(
        path: LogoutEndpoint.path,
        body: const {},
        cancelToken: cancelToken,
      );
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<AuthTokens, ApiError>> socialSignIn(
    SocialSignInRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      final dto = SocialSignInRequestDto.fromEntity(request);
      final response = await api.post<Map<String, dynamic>>(
        path: SocialSignInEndpoint.path(dto),
        body: SocialSignInEndpoint.body(dto),
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<AuthTokens, ApiError>> guestSignIn({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await api.post<Map<String, dynamic>>(
        path: GuestSignInEndpoint.path,
        body: const {},
        cancelToken: cancelToken,
      );
      return Ok(TokensDto.fromJson(response.data).toDomain());
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<void, ApiError>> startPasswordReset(
    PasswordResetStartRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      await api.post(
        path: PasswordResetStartEndpoint.path,
        body: PasswordResetStartEndpoint.body(
          PasswordResetStartRequestDto.fromEntity(request),
        ),
        cancelToken: cancelToken,
      );
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<void, ApiError>> verifyPasswordReset(
    PasswordResetVerifyRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      await api.post(
        path: PasswordResetVerifyEndpoint.path,
        body: PasswordResetVerifyEndpoint.body(
          PasswordResetVerifyRequestDto.fromEntity(request),
        ),
        cancelToken: cancelToken,
      );
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }

  @override
  Future<Result<void, ApiError>> completePasswordReset(
    PasswordResetCompleteRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      await api.post(
        path: PasswordResetCompleteEndpoint.path,
        body: PasswordResetCompleteEndpoint.body(
          PasswordResetCompleteRequestDto.fromEntity(request),
        ),
        cancelToken: cancelToken,
      );
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.error);
    }
  }
}
