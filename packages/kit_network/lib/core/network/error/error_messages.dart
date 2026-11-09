/// Internationalization support for error messages
///
/// Usage:
/// ```dart
/// final errorMessages = ErrorMessages(locale: 'tr_TR');
/// print(errorMessages.networkError); // "Network error"
/// ```
class ErrorMessages {
  final String locale;

  ErrorMessages({this.locale = 'en_US'});

  // Network Errors
  String get networkError => _getMessage('network_error');
  String get connectionTimeout => _getMessage('connection_timeout');
  String get requestCancelled => _getMessage('request_cancelled');
  String get noInternetConnection => _getMessage('no_internet_connection');

  // HTTP Errors
  String get badRequest => _getMessage('bad_request');
  String get unauthorized => _getMessage('unauthorized');
  String get forbidden => _getMessage('forbidden');
  String get notFound => _getMessage('not_found');
  String get methodNotAllowed => _getMessage('method_not_allowed');
  String get requestTimeout => _getMessage('request_timeout');
  String get conflict => _getMessage('conflict');
  String get internalServerError => _getMessage('internal_server_error');
  String get serviceUnavailable => _getMessage('service_unavailable');

  // Parse Errors
  String get parseError => _getMessage('parse_error');
  String get invalidResponse => _getMessage('invalid_response');

  // Cache Errors
  String get cacheError => _getMessage('cache_error');
  String get cacheExpired => _getMessage('cache_expired');

  // Rate Limit Errors
  String get rateLimitExceeded => _getMessage('rate_limit_exceeded');

  // Custom errors
  String customError(String code) => _getMessage('custom_$code');

  String _getMessage(String key) {
    return _messages[locale]?[key] ?? _messages['en_US']![key]!;
  }

  static final Map<String, Map<String, String>> _messages = {
    'en_US': {
      'network_error': 'Network error occurred',
      'connection_timeout': 'Connection timeout',
      'request_cancelled': 'Request was cancelled',
      'no_internet_connection': 'No internet connection',
      'bad_request': 'Bad request',
      'unauthorized': 'Unauthorized access',
      'forbidden': 'Access forbidden',
      'not_found': 'Resource not found',
      'method_not_allowed': 'Method not allowed',
      'request_timeout': 'Request timeout',
      'conflict': 'Conflict occurred',
      'internal_server_error': 'Internal server error',
      'service_unavailable': 'Service unavailable',
      'parse_error': 'Failed to parse response',
      'invalid_response': 'Invalid response format',
      'cache_error': 'Cache operation failed',
      'cache_expired': 'Cached data expired',
      'rate_limit_exceeded': 'Rate limit exceeded',
    },
    'tr_TR': {
      'network_error': 'Ağ hatası oluştu',
      'connection_timeout': 'Bağlantı zaman aşımı',
      'request_cancelled': 'İstek iptal edildi',
      'no_internet_connection': 'İnternet bağlantısı yok',
      'bad_request': 'Hatalı istek',
      'unauthorized': 'Yetkisiz erişim',
      'forbidden': 'Erişim yasak',
      'not_found': 'Kaynak bulunamadı',
      'method_not_allowed': 'Metoda izin verilmiyor',
      'request_timeout': 'İstek zaman aşımı',
      'conflict': 'Çakışma oluştu',
      'internal_server_error': 'Sunucu hatası',
      'service_unavailable': 'Servis kullanılamıyor',
      'parse_error': 'Yanıt ayrıştırılamadı',
      'invalid_response': 'Geçersiz yanıt formatı',
      'cache_error': 'Önbellek işlemi başarısız',
      'cache_expired': 'Önbellek süresi doldu',
      'rate_limit_exceeded': 'İstek limiti aşıldı',
    },
    'es_ES': {
      'network_error': 'Error de red',
      'connection_timeout': 'Tiempo de conexión agotado',
      'request_cancelled': 'Solicitud cancelada',
      'no_internet_connection': 'Sin conexión a Internet',
      'bad_request': 'Solicitud incorrecta',
      'unauthorized': 'Acceso no autorizado',
      'forbidden': 'Acceso prohibido',
      'not_found': 'Recurso no encontrado',
      'method_not_allowed': 'Método no permitido',
      'request_timeout': 'Tiempo de solicitud agotado',
      'conflict': 'Conflicto ocurrido',
      'internal_server_error': 'Error interno del servidor',
      'service_unavailable': 'Servicio no disponible',
      'parse_error': 'Error al analizar respuesta',
      'invalid_response': 'Formato de respuesta inválido',
      'cache_error': 'Operación de caché fallida',
      'cache_expired': 'Datos en caché expirados',
      'rate_limit_exceeded': 'Límite de tasa excedido',
    },
    'de_DE': {
      'network_error': 'Netzwerkfehler aufgetreten',
      'connection_timeout': 'Verbindungs-Timeout',
      'request_cancelled': 'Anfrage wurde abgebrochen',
      'no_internet_connection': 'Keine Internetverbindung',
      'bad_request': 'Fehlerhafte Anfrage',
      'unauthorized': 'Nicht autorisierter Zugriff',
      'forbidden': 'Zugriff verboten',
      'not_found': 'Ressource nicht gefunden',
      'method_not_allowed': 'Methode nicht erlaubt',
      'request_timeout': 'Anfrage-Timeout',
      'conflict': 'Konflikt aufgetreten',
      'internal_server_error': 'Interner Serverfehler',
      'service_unavailable': 'Dienst nicht verfügbar',
      'parse_error': 'Antwort konnte nicht analysiert werden',
      'invalid_response': 'Ungültiges Antwortformat',
      'cache_error': 'Cache-Operation fehlgeschlagen',
      'cache_expired': 'Zwischengespeicherte Daten abgelaufen',
      'rate_limit_exceeded': 'Ratenlimit überschritten',
    },
    'fr_FR': {
      'network_error': 'Erreur réseau',
      'connection_timeout': 'Délai de connexion dépassé',
      'request_cancelled': 'Requête annulée',
      'no_internet_connection': 'Pas de connexion Internet',
      'bad_request': 'Mauvaise requête',
      'unauthorized': 'Accès non autorisé',
      'forbidden': 'Accès interdit',
      'not_found': 'Ressource introuvable',
      'method_not_allowed': 'Méthode non autorisée',
      'request_timeout': 'Délai de requête dépassé',
      'conflict': 'Conflit survenu',
      'internal_server_error': 'Erreur interne du serveur',
      'service_unavailable': 'Service indisponible',
      'parse_error': 'Échec de l\'analyse de la réponse',
      'invalid_response': 'Format de réponse invalide',
      'cache_error': 'Échec de l\'opération de cache',
      'cache_expired': 'Données en cache expirées',
      'rate_limit_exceeded': 'Limite de débit dépassée',
    },
  };

  /// Add custom locale
  static void addLocale(String locale, Map<String, String> messages) {
    _messages[locale] = messages;
  }

  /// Get supported locales
  static List<String> get supportedLocales => _messages.keys.toList();
}

/// Error message provider interface
abstract class ErrorMessageProvider {
  String getMessage(String key, String locale);
}

/// Default error message provider
class DefaultErrorMessageProvider implements ErrorMessageProvider {
  DefaultErrorMessageProvider();

  @override
  String getMessage(String key, String locale) {
    final messages = ErrorMessages(locale: locale);

    switch (key) {
      case 'network_error':
        return messages.networkError;
      case 'connection_timeout':
        return messages.connectionTimeout;
      case 'unauthorized':
        return messages.unauthorized;
      case 'not_found':
        return messages.notFound;
      case 'internal_server_error':
        return messages.internalServerError;
      default:
        return messages.customError(key);
    }
  }
}
