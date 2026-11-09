import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../connectivity/network_info.dart';

/// Callback type to execute requests added to offline queue.
typedef RequestExecutor = Future<void> Function(QueuedRequest request);

/// Offline queue for failed requests
///
/// Features:
/// - Persistent storage (SharedPreferences)
/// - Auto-retry on network restore
/// - Configurable max retry
/// - Request deduplication
class OfflineQueue {
  final SharedPreferences prefs;
  final NetworkInfo networkInfo;
  final RequestExecutor executor;
  final int maxRetries;
  final String _key = 'offline_queue';
  final List<QueuedRequest> _queue = [];
  StreamSubscription<bool>? _connectivitySubscription;
  bool _initialized = false;
  bool _processing = false;

  OfflineQueue({
    required this.prefs,
    required this.networkInfo,
    required this.executor,
    this.maxRetries = 3,
  });

  /// Async init — async call cannot be made in constructor, so it is separate.
  Future<void> init() async {
    await _loadQueue();
    _listenToConnectivity();
    _initialized = true;
  }

  /// Add request to offline queue
  Future<void> enqueue(QueuedRequest request) async {
    assert(_initialized, 'OfflineQueue.init() must be called first');

    // Avoid duplicates
    if (_queue.any((r) => r.id == request.id)) return;

    _queue.add(request);
    await _saveQueue();
  }

  /// Process all queued requests
  Future<void> processQueue() async {
    if (_queue.isEmpty || _processing) return;

    final hasConnection = await networkInfo.isConnected;
    if (!hasConnection) return;

    _processing = true;
    try {
      final requests = List<QueuedRequest>.from(_queue);

      for (final request in requests) {
        try {
          await executor(request);
          _queue.remove(request);
        } catch (_) {
          request.incrementRetryCount();
          if (request.retryCount > maxRetries) {
            _queue.remove(request);
          }
        }
      }

      await _saveQueue();
    } finally {
      _processing = false;
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (isConnected) processQueue();
    });
  }

  Future<void> _loadQueue() async {
    final json = prefs.getString(_key);
    if (json == null) return;

    try {
      final List<dynamic> list = jsonDecode(json);
      _queue.clear();
      _queue.addAll(
        list.map((e) => QueuedRequest.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {
      await prefs.remove(_key);
    }
  }

  Future<void> _saveQueue() async {
    final json = jsonEncode(_queue.map((r) => r.toJson()).toList());
    await prefs.setString(_key, json);
  }

  Future<void> clear() async {
    _queue.clear();
    await prefs.remove(_key);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;

  OfflineQueueStatus get status => OfflineQueueStatus(
    queueSize: _queue.length,
    oldestRequest: _queue.isEmpty
        ? null
        : _queue
              .reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b)
              .timestamp,
  );
}

/// Queued request model
class QueuedRequest {
  final String id;
  final String method;
  final String url;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? headers;
  final DateTime timestamp;
  int retryCount;

  QueuedRequest({
    required this.id,
    required this.method,
    required this.url,
    this.body,
    this.headers,
    DateTime? timestamp,
    this.retryCount = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  void incrementRetryCount() {
    retryCount++;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'method': method,
    'url': url,
    'body': body,
    'headers': headers,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory QueuedRequest.fromJson(Map<String, dynamic> json) => QueuedRequest(
    id: json['id'] as String,
    method: json['method'] as String,
    url: json['url'] as String,
    body: json['body'] as Map<String, dynamic>?,
    headers: json['headers'] as Map<String, dynamic>?,
    timestamp: DateTime.parse(json['timestamp'] as String),
    retryCount: json['retryCount'] as int? ?? 0,
  );
}

class OfflineQueueStatus {
  final int queueSize;
  final DateTime? oldestRequest;

  OfflineQueueStatus({required this.queueSize, this.oldestRequest});

  @override
  String toString() =>
      'OfflineQueueStatus(queueSize: $queueSize, oldestRequest: $oldestRequest)';
}
