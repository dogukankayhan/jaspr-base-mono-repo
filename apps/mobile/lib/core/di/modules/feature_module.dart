import 'package:app_shared/data/repository/user_repository_impl.dart';
import 'package:app_shared/domain/repository/user_repository.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:get_it/get_it.dart';

void setupFeatureModule(GetIt getIt) {
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<ApiManager>()),
  );
}
