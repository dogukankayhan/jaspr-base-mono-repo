import 'package:dio/dio.dart';
import '../../../../core/network/api/api_manager_interface.dart';
import '../../../../core/network/api/api_response.dart';
import '../../../../shared/constants/api_routes.dart';
import '../dto/user_dto.dart';

class UserService {
  final ApiManager api;
  UserService(this.api);

  Future<ApiResponse<UserDTO>> getUser(String id, {CancelToken? cancelToken}) {
    return api.get<UserDTO>(
      path: ApiRoutes.userById(id),
      fromJson: UserDTO.fromJson,
      cancelToken: cancelToken,
    );
  }
}
