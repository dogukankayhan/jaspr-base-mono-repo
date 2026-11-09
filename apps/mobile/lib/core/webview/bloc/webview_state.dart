import 'package:flutter_kit_core/base_bloc/base_state.dart';

import '../model/webview_result.dart';

enum WebViewStatus { initial, loading, loaded, intercepted, error }

final class WebViewState extends BaseState {
  final WebViewStatus webViewStatus;
  final String? currentUrl;
  final int progress;
  final WebViewResult<dynamic>? result;

  const WebViewState({
    super.isLoading = false,
    super.errorMessage,
    this.webViewStatus = WebViewStatus.initial,
    this.currentUrl,
    this.progress = 0,
    this.result,
  });

  WebViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    WebViewStatus? webViewStatus,
    String? currentUrl,
    int? progress,
    WebViewResult<dynamic>? result,
  }) {
    return WebViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      webViewStatus: webViewStatus ?? this.webViewStatus,
      currentUrl: currentUrl ?? this.currentUrl,
      progress: progress ?? this.progress,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    webViewStatus,
    currentUrl,
    progress,
    result,
  ];
}
