extension FutureExt<T> on Future<T> {
  /// Awaits this future, returning `null` instead of throwing if it doesn't
  /// complete within [duration]. Useful for best-effort calls.
  Future<T?> timeoutOrNull(Duration duration) {
    return then<T?>((value) => value).timeout(
      duration,
      onTimeout: () => null,
    );
  }
}
