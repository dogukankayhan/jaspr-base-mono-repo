import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_ui/jaspr_kit_ui.dart';

import '../../features/pokemon_home/pokemon_home_navigator.dart';

/// Page chrome shared by every route (header + content area).
/// Reused across features → a normal public component in core/components.
class AppShell extends StatelessComponent {
  const AppShell({required this.child, super.key});

  final Component child;

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      header(classes: 'app-header', [
        PokemonHomeNavigator.link(
          classes: 'app-logo',
          child: Component.text('Pokédex'),
        ),
        span(classes: 'app-subtitle', [
          Component.text('Jaspr · shared blocs with mobile'),
        ]),
      ]),
      main_(classes: 'app-content', [child]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.app-header').styles(
      raw: {
        'display': 'flex',
        'align-items': 'baseline',
        'gap': '16px',
        'padding': '16px 24px',
        'background-color': 'var(--kit-primary)',
        'color': 'var(--kit-onPrimary)',
      },
    ),
    css('.app-logo').styles(
      color: KitColors.onPrimary,
      raw: {
        'font-size': '1.5rem',
        'font-weight': '700',
        'text-decoration': 'none',
      },
    ),
    css('.app-subtitle').styles(raw: {'opacity': '0.8', 'font-size': '0.9rem'}),
    css('.app-content').styles(
      raw: {'max-width': '1080px', 'margin': '0 auto', 'padding': '24px'},
    ),
  ];
}
