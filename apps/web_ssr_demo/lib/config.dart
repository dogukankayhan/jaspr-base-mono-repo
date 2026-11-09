/// API base URL (same --dart-define as apps/web).
const String apiBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://pokeapi.co/api/v2/',
);

/// Public origin of the site, e.g. `https://pokedex.example.com` — used for
/// canonical / og:url / sitemap URLs. Empty → derived from the request
/// (fine locally; set it in production behind a proxy/CDN).
const String siteUrl = String.fromEnvironment('SITE_URL');

/// Page size of the list (server-rendered pages and infinite scroll).
const int pageSize = 20;
