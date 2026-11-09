import 'package:flutter_kit_network/core/config/environment_config.dart';
import 'package:get_it/get_it.dart';

import 'modules/auth_module.dart';
import 'modules/feature_module.dart';
import 'modules/local_module.dart';
import 'modules/navigation_module.dart';
import 'modules/network_module.dart';
import 'modules/pokemon_module.dart';

final getIt = GetIt.instance;

class Injection {
  Injection._();

  static Future<void> init({required EnvironmentConfig config}) async {
    await setupNetworkModule(getIt, config: config);
    await setupAuthModule(getIt);
    setupNavigationModule(getIt);
    setupLocalModule(getIt);
    setupFeatureModule(getIt);
    setupPokemonModule(getIt);
  }

  static Future<void> reset() async => getIt.reset();
}
