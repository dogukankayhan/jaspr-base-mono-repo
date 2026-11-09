import 'package:kit_network/core/config/environment_config.dart';
import 'package:kit_network/core/di/locator.dart';

import 'modules/auth_module.dart';
import 'modules/network_module.dart';
import 'modules/pokemon_module.dart';

/// Web DI entry point — mirrors apps/mobile's `Injection` and its MANDATORY
/// module order (see CLAUDE.md Critical Pattern 5):
///
/// 1. network → TokenStore, NetworkInfo, ApiManager
/// 2. auth    → AuthManager, AuthBloc   (needs ApiManager + TokenStore)
/// 3. feature repositories
///
/// Same GetIt instance as every shared package (`kit_network`'s `getIt`), so
/// `XxxBloc.create` factories in app_shared resolve identically on both
/// platforms.
abstract final class Injection {
  static Future<void> init({required EnvironmentConfig config}) async {
    setupNetworkModule(getIt, config: config);
    await setupAuthModule(getIt);
    setupPokemonModule(getIt);
  }

  static Future<void> reset() => getIt.reset();
}
