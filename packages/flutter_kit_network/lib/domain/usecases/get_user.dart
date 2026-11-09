import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUser {
  final UserRepository repo;
  GetUser(this.repo);

  Future<User> call(String id) => repo.getUser(id);
}
