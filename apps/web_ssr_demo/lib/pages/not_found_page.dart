import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

/// Shared error page with a **real HTTP status** — 404 for missing pages (not
/// "200 + error text", a soft 404 search engines index as junk), 503 when the
/// data source is down (tells bots to retry instead of dropping the URL).
class NotFoundPage extends StatelessComponent {
  const NotFoundPage({this.message = 'Page not found', super.key})
    : statusCode = 404;

  const NotFoundPage.unavailable({super.key})
    : message = 'Temporarily unavailable — please try again shortly.',
      statusCode = 503;

  final String message;
  final int statusCode;

  @override
  Component build(BuildContext context) {
    context.setStatusCode(statusCode);
    return Component.fragment([
      Document.head(
        title: statusCode == 404
            ? 'Not found · Pokédex'
            : 'Unavailable · Pokédex',
        meta: {'robots': 'noindex,follow'},
      ),
      section(classes: 'not-found', [
        h1([Component.text(message)]),
        p([
          a(href: '/', [Component.text('← Back to all Pokémon')]),
        ]),
      ]),
    ]);
  }
}
