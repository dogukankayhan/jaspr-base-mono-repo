import 'dart:convert';
import 'dart:io';

/// Minimal in-process HTTP server for integration tests.
/// Uses port 0 so the OS assigns a free port — no conflicts in parallel runs.
class LocalTestServer {
  final HttpServer _server;

  LocalTestServer._(this._server);

  String get baseUrl => 'http://localhost:${_server.port}';

  static Future<LocalTestServer> start({
    required Future<void> Function(HttpRequest) handler,
  }) async {
    final server = await HttpServer.bind('localhost', 0);
    server.listen(handler);
    return LocalTestServer._(server);
  }

  Future<void> close() => _server.close(force: true);
}

// ─── Ready-made handlers ───────────────────────────────────────────────────

/// Always returns [statusCode] with an empty JSON body.
Future<void> Function(HttpRequest) fixedStatus(int statusCode) =>
    (req) async {
      req.response
        ..statusCode = statusCode
        ..headers.contentType = ContentType.json
        ..write('{}');
      await req.response.close();
    };

/// Echoes request headers back as JSON (mirrors httpbin's /anything).
Future<void> echoHeaders(HttpRequest req) async {
  final headers = <String, String>{};
  req.headers.forEach((name, values) {
    headers[name] = values.join(', ');
  });
  req.response
    ..statusCode = 200
    ..headers.contentType = ContentType.json
    ..write(jsonEncode({'headers': headers, 'method': req.method}));
  await req.response.close();
}

/// Returns 500 for the first [failCount] requests, then 200.
Future<void> Function(HttpRequest) failThenSucceed(int failCount) {
  var calls = 0;
  return (req) async {
    calls++;
    final sc = calls <= failCount ? 500 : 200;
    req.response
      ..statusCode = sc
      ..headers.contentType = ContentType.json
      ..write('{}');
    await req.response.close();
  };
}

/// Delays [duration] before responding with [statusCode].
Future<void> Function(HttpRequest) delayed(
  Duration duration, {
  int statusCode = 200,
}) =>
    (req) async {
      await Future<void>.delayed(duration);
      req.response
        ..statusCode = statusCode
        ..headers.contentType = ContentType.json
        ..write('{}');
      await req.response.close();
    };
