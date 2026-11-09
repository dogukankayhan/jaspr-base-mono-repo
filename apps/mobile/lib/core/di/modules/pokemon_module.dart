import 'package:app_shared/data/repository/favorites_repository_impl.dart';
import 'package:app_shared/data/repository/pokemon_repository_impl.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasource/favorites_local_datasource.dart';

void setupPokemonModule(GetIt getIt) {
  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(getIt<ApiManager>()),
  );

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: SharedPrefsFavoritesDataSource(getIt<SharedPreferences>()),
      pokemonRepository: getIt<PokemonRepository>(),
    ),
  );
}
