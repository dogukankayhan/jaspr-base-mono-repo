import 'package:app_shared/domain/constants/pokemon_types.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:app_shared/domain/usecase/list_all_pokemon_usecase.dart';
import 'package:kit_network/core/di/locator.dart';
import 'package:shelf/shelf.dart';

import '../config.dart';

/// `/robots.txt` and `/sitemap.xml` — plain-text/XML responses served next to
/// the Jaspr pages (see main.server.dart).
abstract final class CrawlerFiles {
  static String _origin(Request request) =>
      siteUrl.isNotEmpty ? siteUrl : request.requestedUri.origin;

  static Response robots(Request request) => Response.ok(
    '''
# Pokédex — crawl rules
User-agent: *
Allow: /
# Personal page (favorites live in each visitor's browser).
Disallow: /favorites

# AI answer engines are explicitly welcome (AEO). Change here if that
# decision changes.
User-agent: GPTBot
User-agent: ClaudeBot
User-agent: PerplexityBot
User-agent: Google-Extended
Allow: /
Disallow: /favorites

Sitemap: ${_origin(request)}/sitemap.xml
''',
    headers: {'content-type': 'text/plain; charset=utf-8'},
  );

  /// Built once per server process — the Pokémon list is public and rarely
  /// changes. Retried on the next request if building it failed.
  static Future<String>? _sitemapXml;

  static Future<Response> sitemap(Request request) async {
    final origin = _origin(request);
    try {
      final xml = await (_sitemapXml ??= _buildSitemap(origin));
      return Response.ok(
        xml,
        headers: {
          'content-type': 'application/xml; charset=utf-8',
          'cache-control': 'public, max-age=3600',
        },
      );
    } catch (_) {
      _sitemapXml = null;
      return Response(503, body: 'Sitemap temporarily unavailable');
    }
  }

  static Future<String> _buildSitemap(String origin) async {
    final result = await ListAllPokemonUseCase(getIt<PokemonRepository>())();
    final briefs = result.when(ok: (list) => list, err: (e) => throw e);

    final urls = <String>[
      '$origin/',
      for (final type in PokemonTypes.filterable) '$origin/?type=$type',
      for (final brief in briefs)
        if (brief.id case final id?) '$origin/pokemon/$id',
    ];

    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');
    for (final url in urls) {
      buffer.writeln('  <url><loc>${_xmlEscape(url)}</loc></url>');
    }
    buffer.writeln('</urlset>');
    return buffer.toString();
  }

  static String _xmlEscape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
