import '../utils/result.dart';

extension ResultExtension<T, E> on Result<T, E> {
  /// Get value or null
  T? getOrNull() {
    return when(ok: (data) => data, err: (_) => null);
  }

  /// Get error or null
  E? getErrorOrNull() {
    return when(ok: (_) => null, err: (error) => error);
  }

  /// Get value or default
  T getOrElse(T defaultValue) {
    return when(ok: (data) => data, err: (_) => defaultValue);
  }

  /// Get value or compute default
  T getOrElseCompute(T Function() defaultValue) {
    return when(ok: (data) => data, err: (_) => defaultValue());
  }

  /// Map success value
  Result<R, E> map<R>(R Function(T data) mapper) {
    return when(ok: (data) => Ok(mapper(data)), err: (error) => Err(error));
  }

  /// Map error value
  Result<T, F> mapError<F>(F Function(E error) mapper) {
    return when(ok: (data) => Ok(data), err: (error) => Err(mapper(error)));
  }

  /// FlatMap for chaining operations
  Result<R, E> flatMap<R>(Result<R, E> Function(T data) mapper) {
    return when(ok: (data) => mapper(data), err: (error) => Err(error));
  }

  /// Convert to Future
  Future<T> toFuture() async {
    return when(ok: (data) => data, err: (error) => throw error as Object);
  }

  /// Fold into a single type
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(E error) onError,
  }) {
    return when(ok: onSuccess, err: onError);
  }

  /// Execute side effects
  Result<T, E> onSuccess(void Function(T data) action) {
    if (this is Ok<T, E>) {
      action((this as Ok<T, E>).value);
    }
    return this;
  }

  Result<T, E> onError(void Function(E error) action) {
    if (this is Err<T, E>) {
      action((this as Err<T, E>).error);
    }
    return this;
  }

  /// Swap Ok and Err
  Result<E, T> swap() {
    return when(ok: (data) => Err(data), err: (error) => Ok(error));
  }
}

extension FutureResultExtension<T, E> on Future<Result<T, E>> {
  /// Map async result
  Future<Result<R, E>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    final result = await this;
    return result.when(
      ok: (data) async => Ok(await mapper(data)),
      err: (error) => Err(error),
    );
  }

  /// FlatMap async
  Future<Result<R, E>> flatMapAsync<R>(
    Future<Result<R, E>> Function(T data) mapper,
  ) async {
    final result = await this;
    return result.when(ok: (data) => mapper(data), err: (error) => Err(error));
  }

  /// Get value or null async
  Future<T?> getOrNullAsync() async {
    final result = await this;
    return result.getOrNull();
  }

  /// Get value or default async
  Future<T> getOrElseAsync(T defaultValue) async {
    final result = await this;
    return result.getOrElse(defaultValue);
  }
}
