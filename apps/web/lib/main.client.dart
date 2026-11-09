/// Client entrypoint — compiled to JavaScript and run in the browser.
library;

import 'package:jaspr/client.dart';

import 'app.dart';
import 'core/config/web_environment.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  // Same order as mobile's initialize(): config → DI → app.
  await Injection.init(config: WebEnvironment.config);
  runApp(const App());
}
