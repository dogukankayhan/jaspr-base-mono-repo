import '../sources/remote/dto/user_dto.dart';
import '../../domain/entities/user.dart' as domain;

class UserMapper {
  static domain.User toEntity(UserDTO dto) =>
      domain.User(id: dto.id, name: dto.name, email: dto.email);
}
