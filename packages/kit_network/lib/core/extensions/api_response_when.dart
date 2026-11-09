import '../network/api/api_response.dart';
import '../network/error/api_error.dart';

// ignore: unintended_html_in_doc_comment
/// ApiResponse<T> .when(...) syntactic sugar.
/// Doing duck-typing based on the ApiResponse shape in your project.
extension ApiResponseWhenX<T> on ApiResponse<T> {
  R when<R>({
    required R Function(T data) ok,
    required R Function(ApiError error) err,
  }) {
    final self = this as dynamic;

    // 1) isSuccess / data / error pattern
    try {
      final bool isSuccess = (self.isSuccess as bool?) ?? false;
      if (isSuccess) {
        return ok(self.data as T);
      } else {
        return err(self.error as ApiError);
      }
    } catch (_) {}

    // 2) status / value pattern
    try {
      final String status = (self.status as String?) ?? '';
      if (status.toLowerCase() == 'success') {
        return ok(self.data as T);
      } else {
        return err(self.error as ApiError);
      }
    } catch (_) {}

    // 3) success subclass pattern: ApiSuccess<T> / ApiFailure<T>
    if (self.runtimeType.toString().toLowerCase().contains('success')) {
      return ok((self.data as T));
    }
    if (self.runtimeType.toString().toLowerCase().contains('failure') ||
        self.runtimeType.toString().toLowerCase().contains('error')) {
      return err(self.error as ApiError);
    }

    throw StateError(
      'ApiResponse.when: Tanınmayan ApiResponse şekli. Lütfen adaptörü projene göre ayarla.',
    );
  }
}
