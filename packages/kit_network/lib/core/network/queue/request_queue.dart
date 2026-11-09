import 'dart:async';
import 'dart:collection';
import '../api/api_manager_interface.dart';

/// Request queue with priority management
///
/// Features:
/// - Priority-based execution
/// - Concurrent request limiting
/// - Queue pause/resume
/// - Request cancellation
class RequestQueue {
  final int maxConcurrent;
  final Queue<_QueuedRequest> _queue = Queue();
  int _activeRequests = 0;
  bool _isPaused = false;

  RequestQueue({this.maxConcurrent = 3});

  /// Enqueue a request with priority
  Future<T> enqueue<T>(
    Future<T> Function() request, {
    RequestPriority priority = RequestPriority.normal,
    String? id,
  }) {
    final completer = Completer<T>();
    final queuedRequest = _QueuedRequest<T>(
      request: request,
      completer: completer,
      priority: priority,
      id: id,
    );

    _queue.add(queuedRequest);
    _sortQueue();
    _processQueue();

    return completer.future;
  }

  /// Sort queue by priority (highest first)
  void _sortQueue() {
    final list = _queue.toList();
    list.sort((a, b) => b.priority.value.compareTo(a.priority.value));
    _queue.clear();
    _queue.addAll(list);
  }

  /// Process queued requests
  Future<void> _processQueue() async {
    if (_isPaused || _activeRequests >= maxConcurrent || _queue.isEmpty) {
      return;
    }

    final queuedRequest = _queue.removeFirst();
    _activeRequests++;

    try {
      final result = await queuedRequest.request();
      queuedRequest.completer.complete(result);
    } catch (e, stackTrace) {
      queuedRequest.completer.completeError(e, stackTrace);
    } finally {
      _activeRequests--;
      _processQueue(); // Process next
    }
  }

  /// Pause queue processing
  void pause() {
    _isPaused = true;
  }

  /// Resume queue processing
  void resume() {
    _isPaused = false;
    _processQueue();
  }

  /// Cancel all pending requests
  void cancelAll() {
    while (_queue.isNotEmpty) {
      final request = _queue.removeFirst();
      request.completer.completeError(Exception('Request cancelled'));
    }
  }

  /// Cancel request by ID. Returns false if not found.
  bool cancel(String id) {
    final index = _queue.toList().indexWhere((r) => r.id == id);
    if (index == -1) return false;

    final list = _queue.toList();
    final request = list.removeAt(index);
    _queue.clear();
    _queue.addAll(list);

    request.completer.completeError(Exception('Request cancelled'));

    return true;
  }

  /// Get queue status
  QueueStatus get status => QueueStatus(
    pending: _queue.length,
    active: _activeRequests,
    isPaused: _isPaused,
  );

  /// Clear queue and reset
  void clear() {
    cancelAll();
    _activeRequests = 0;
    _isPaused = false;
  }
}

class _QueuedRequest<T> {
  final Future<T> Function() request;
  final Completer<T> completer;
  final RequestPriority priority;
  final String? id;

  _QueuedRequest({
    required this.request,
    required this.completer,
    required this.priority,
    this.id,
  });
}

class QueueStatus {
  final int pending;
  final int active;
  final bool isPaused;

  QueueStatus({
    required this.pending,
    required this.active,
    required this.isPaused,
  });

  @override
  String toString() =>
      'QueueStatus(pending: $pending, active: $active, isPaused: $isPaused)';
}
