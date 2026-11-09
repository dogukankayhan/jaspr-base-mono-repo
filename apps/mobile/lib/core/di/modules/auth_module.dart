import 'package:flutter_kit_auth/flutter_kit_auth.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart'
    as netapi;
import 'package:get_it/get_it.dart';

Future<void> setupAuthModule(GetIt getIt) async {
  await setupAuth(
    getIt: getIt,
    apiManager: getIt<netapi.ApiManager>(),
    tokenStore: getIt<TokenStore>(),
    refreshApiManager: getIt<netapi.ApiManager>(
      instanceName: 'refreshApiManager',
    ),
  );
}
