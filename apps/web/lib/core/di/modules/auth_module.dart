import 'package:get_it/get_it.dart';
import 'package:kit_auth/auth/token/token_store.dart';
import 'package:kit_auth/auth_core_setup.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';

/// Same AuthManager + AuthBloc as mobile (kit_auth's [setupAuthCore]); web has
/// no Google/Apple native sign-in, so flutter_kit_auth's extras are skipped.
Future<void> setupAuthModule(GetIt getIt) => setupAuthCore(
  getIt: getIt,
  apiManager: getIt<ApiManager>(),
  tokenStore: getIt<TokenStore>(),
  refreshApiManager: getIt<ApiManager>(instanceName: 'refreshApiManager'),
);
