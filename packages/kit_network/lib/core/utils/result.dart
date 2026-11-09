sealed class Result<T, E> {
  const Result();
  R when<R>({required R Function(T data) ok, required R Function(E error) err});
  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(E error) err,
  }) => ok(value);
}

class Err<T, E> extends Result<T, E> {
  final E error;
  const Err(this.error);

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(E error) err,
  }) => err(error);
}
