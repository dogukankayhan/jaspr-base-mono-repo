import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/user_repository.dart';
import '../mappers/user_mapper.dart';
import '../sources/remote/services/user_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService service;
  UserRepositoryImpl(this.service);

  @override
  Future<domain.User> getUser(String id) async {
    final res = await service.getUser(id);
    return UserMapper.toEntity(res.data);
  }
}
