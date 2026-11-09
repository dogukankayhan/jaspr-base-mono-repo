import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import '../config.dart';

/// Absolute origin for canonical / og:url / sitemap links.
String siteOrigin(BuildContext context) {
  if (siteUrl.isNotEmpty) return siteUrl;
  final headers = context.headers;
  final scheme = headers['x-forwarded-proto'] ?? 'http';
  return '$scheme://${headers['host'] ?? 'localhost:8080'}';
}

/// One place that renders a page's `<head>` SEO tags, so every page gets the
/// same complete set: title, description, canonical, robots, Open Graph,
/// Twitter card and JSON-LD structured data.
Component seoHead({
  required BuildContext context,
  required String title,
  required String description,
  required String path,
  String? image,
  bool index = true,
  String ogType = 'website',
  List<Map<String, Object?>> jsonLd = const [],
}) {
  final url = '${siteOrigin(context)}$path';
  return Document.head(
    title: title,
    meta: {
      'description': description,
      // noindex,follow: keep the page out of results but let bots follow links.
      'robots': index ? 'index,follow' : 'noindex,follow',
      'twitter:card': image != null ? 'summary_large_image' : 'summary',
      'twitter:title': title,
      'twitter:description': description,
      'twitter:image': ?image,
    },
    children: [
      if (index)
        Component.element(
          tag: 'link',
          attributes: {'rel': 'canonical', 'href': url},
        ),
      _og('og:type', ogType),
      _og('og:site_name', 'Pokédex'),
      _og('og:title', title),
      _og('og:description', description),
      _og('og:url', url),
      if (image != null) _og('og:image', image),
      for (final data in jsonLd) jsonLdScript(data),
    ],
  );
}

Component _og(String property, String content) => Component.element(
  tag: 'meta',
  attributes: {'property': property, 'content': content},
);

/// `<script type="application/ld+json">` with the JSON escaped so that data
/// (e.g. a description containing `</script>`) can never end the tag early.
Component jsonLdScript(Map<String, Object?> data) {
  final json = jsonEncode(data).replaceAll('<', r'<');
  return Component.element(
    tag: 'script',
    attributes: {'type': 'application/ld+json'},
    children: [RawText(json)],
  );
}
