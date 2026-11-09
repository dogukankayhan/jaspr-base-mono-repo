sealed class WebViewResult<T> {
  const WebViewResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
    required R Function() dismissed,
  });
}

final class WebViewSuccess<T> extends WebViewResult<T> {
  final T data;
  const WebViewSuccess(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
    required R Function() dismissed,
  }) => success(data);
}

final class WebViewFailure<T> extends WebViewResult<T> {
  final String message;
  final int? statusCode;
  const WebViewFailure(this.message, {this.statusCode});

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
    required R Function() dismissed,
  }) => failure(message, statusCode);
}

final class WebViewDismissed<T> extends WebViewResult<T> {
  const WebViewDismissed();

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
    required R Function() dismissed,
  }) => dismissed();
}
