import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'core/navigation/app_navigator.dart';
import 'core/theme/app_styles.dart';

/// Root component. Routing is owned by [AppNavigator]; global styles by
/// `core/theme/app_styles.dart`.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) => AppNavigator.router();

  @css
  static List<StyleRule> get styles => globalStyles;
}
