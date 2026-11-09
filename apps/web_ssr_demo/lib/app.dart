import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_ui/jaspr_kit_ui.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/detail_server_page.dart';
import 'pages/favorites_server_page.dart';
import 'pages/home_server_page.dart';
import 'pages/not_found_page.dart';

/// Server-side routing (multi-page): every URL is a real request the server
/// answers with finished HTML. Links between pages are plain `<a href>`.
///
/// This component only runs on the server; the browser receives just the
/// `@client` islands inside the pages.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'app', [
      header(classes: 'app-header', [
        a(href: '/', classes: 'app-logo', [Component.text('Pokédex')]),
        span(classes: 'app-subtitle', [
          Component.text('Jaspr SSR · rendered on the server'),
        ]),
        // Site navigation landmark; top-right favorites link (a real page
        // request). The label is Turkish inside an English page → lang="tr".
        nav(
          classes: 'app-nav',
          attributes: const {'aria-label': 'Main'},
          [
            a(
              href: '/favorites',
              classes: 'app-favorites',
              attributes: const {'lang': 'tr'},
              [Component.text('★ Favorilerim')],
            ),
          ],
        ),
      ]),
      main_(classes: 'app-content', [
        Router(
          // Unknown URLs → real 404 (was: 200 with the router's error text).
          errorBuilder: (context, state) => const NotFoundPage(),
          routes: [
            Route(
              path: '/',
              builder: (context, state) => HomeServerPage(
                query: state.queryParams['q'],
                type: state.queryParams['type'],
                page: int.tryParse(state.queryParams['page'] ?? '') ?? 1,
              ),
            ),
            Route(
              path: '/favorites',
              builder: (context, state) => const FavoritesServerPage(),
            ),
            Route(
              path: '/pokemon/:id',
              builder: (context, state) {
                final id = int.tryParse(state.params['id'] ?? '');
                return id == null
                    ? const NotFoundPage()
                    : DetailServerPage(id: id);
              },
            ),
          ],
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    ...kitGlobalStyles,
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
      raw: {
        'color': 'inherit',
        'font-size': '1.5rem',
        'font-weight': '700',
        'text-decoration': 'none',
      },
    ),
    css('.app-nav').styles(raw: {'margin-left': 'auto'}),
    // Visually hidden but read by screen readers and bots.
    css('.sr-only').styles(
      raw: {
        'position': 'absolute',
        'width': '1px',
        'height': '1px',
        'padding': '0',
        'margin': '-1px',
        'overflow': 'hidden',
        'clip': 'rect(0,0,0,0)',
        'white-space': 'nowrap',
        'border': '0',
      },
    ),
    css('.app-favorites').styles(
      raw: {
        'display': 'inline-block',
        'padding': '8px 16px',
        'border-radius': '999px',
        'background': 'rgba(255,255,255,.18)',
        'color': 'inherit',
        'font-weight': '600',
        'text-decoration': 'none',
      },
    ),
    css(
      '.app-favorites:hover',
    ).styles(raw: {'background': 'rgba(255,255,255,.3)'}),
    css('.footer').styles(
      raw: {
        'display': 'flex',
        'justify-content': 'center',
        'gap': '12px',
        'padding': '24px',
        'color': 'var(--kit-gray-50)',
      },
    ),
    css('.app-subtitle').styles(raw: {'opacity': '0.8', 'font-size': '0.9rem'}),
    css('.app-content').styles(
      raw: {'max-width': '1080px', 'margin': '0 auto', 'padding': '24px'},
    ),
  ];
}
