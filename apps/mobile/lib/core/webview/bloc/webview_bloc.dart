import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc.dart';

import '../config/webview_config.dart';
import '../internal/xhr_js.dart';
import '../js/js_injection.dart';
import '../model/webview_result.dart';
import 'webview_event.dart';
import 'webview_state.dart';

final class WebViewBloc extends BaseBloc<WebViewEvent, WebViewState> {
  final WebViewConfig config;
  InAppWebViewController? _controller;

  WebViewBloc({required this.config}) : super(const WebViewState()) {
    on<WebViewControllerCreated>(_onControllerCreated);
    on<WebViewPageStarted>(_onPageStarted);
    on<WebViewProgressChanged>(_onProgressChanged);
    on<WebViewPageFinished>(_onPageFinished);
    on<WebViewNavigationRequested>(_onNavigationRequested);
    on<WebViewXhrResponseReceived>(_onXhrResponseReceived);
    on<WebViewErrorOccurred>(_onErrorOccurred);
    on<WebViewDismissRequested>(_onDismissRequested);
  }

  // ── public API ────────────────────────────────────────────────────────────

  UnmodifiableListView<UserScript> get initialUserScripts {
    final scripts = <UserScript>[];

    if (config.requestInterceptors.isNotEmpty) {
      scripts.add(
        UserScript(
          source: kXhrInterceptorJs,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      );
    }

    for (final js in config.jsInjections) {
      if (js.injectionTime == InjectionTime.atDocumentStart) {
        scripts.add(
          UserScript(
            source: js.code,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          ),
        );
      }
    }

    return UnmodifiableListView(scripts);
  }

  /// Synchronously decides whether to block navigation and fires the matching
  /// event. Called by [AppWebView] inside [shouldOverrideUrlLoading].
  NavigationActionPolicy decideNavigation(String url) {
    debugPrint('[WebView] 🔀 Navigation → $url');
    final uri = Uri.tryParse(url);
    final params = uri?.queryParameters ?? {};

    for (final interceptor in config.urlInterceptors) {
      if (interceptor.matches(url)) {
        final result = interceptor.handle(url, params);
        if (result != null) {
          debugPrint('[WebView] 🚫 URL intercepted → $url');
          add(WebViewNavigationRequested(url, interceptedResult: result));
          return NavigationActionPolicy.CANCEL;
        }
      }
    }

    add(WebViewNavigationRequested(url));
    return NavigationActionPolicy.ALLOW;
  }

  Future<dynamic> evaluateJavascript(String code) =>
      _controller?.evaluateJavascript(source: code) ?? Future.value(null);

  Future<void> loadUrl(String url) async {
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  Future<void> reload() async => _controller?.reload();

  // ── event handlers ────────────────────────────────────────────────────────

  Future<void> _onControllerCreated(
    WebViewControllerCreated event,
    Emitter<WebViewState> emit,
  ) async {
    debugPrint('[WebView] ✅ Controller ready');
    _controller = event.controller;

    if (config.requestInterceptors.isNotEmpty) {
      _controller!.addJavaScriptHandler(
        handlerName: '_wk_xhr',
        callback: (args) {
          if (args.isNotEmpty) {
            add(WebViewXhrResponseReceived(args.first as String));
          }
        },
      );
    }

    for (final ch in config.jsChannels) {
      _controller!.addJavaScriptHandler(
        handlerName: ch.name,
        callback: (args) => ch.handler(args.isNotEmpty ? args.first : null),
      );
    }
  }

  void _onPageStarted(WebViewPageStarted event, Emitter<WebViewState> emit) {
    debugPrint('[WebView] 🌐 Page started → ${event.url}');
    emit(
      state.copyWith(
        webViewStatus: WebViewStatus.loading,
        currentUrl: event.url,
        isLoading: true,
      ),
    );
  }

  void _onProgressChanged(
    WebViewProgressChanged event,
    Emitter<WebViewState> emit,
  ) {
    emit(state.copyWith(progress: event.progress));
  }

  Future<void> _onPageFinished(
    WebViewPageFinished event,
    Emitter<WebViewState> emit,
  ) async {
    debugPrint('[WebView] ✅ Page finished → ${event.url}');
    emit(
      state.copyWith(
        webViewStatus: WebViewStatus.loaded,
        currentUrl: event.url,
        isLoading: false,
      ),
    );

    for (final js in config.jsInjections) {
      if (js.injectionTime == InjectionTime.atDocumentEnd) {
        await _controller?.evaluateJavascript(source: js.code);
      }
    }
  }

  void _onNavigationRequested(
    WebViewNavigationRequested event,
    Emitter<WebViewState> emit,
  ) {
    emit(state.copyWith(currentUrl: event.url));

    if (event.interceptedResult != null) {
      emit(
        state.copyWith(
          webViewStatus: WebViewStatus.intercepted,
          result: event.interceptedResult,
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onXhrResponseReceived(
    WebViewXhrResponseReceived event,
    Emitter<WebViewState> emit,
  ) async {
    try {
      final map = jsonDecode(event.payload) as Map<String, dynamic>;
      final url = map['url'] as String? ?? '';
      final method = (map['method'] as String? ?? 'GET').toUpperCase();
      final statusCode = (map['status'] as num?)?.toInt() ?? 0;
      final body = map['body'] as String?;

      debugPrint('[WebView] 📡 XHR $method $statusCode → $url');
      debugPrint(
        '[WebView]    body: ${body?.substring(0, body.length.clamp(0, 200))}',
      );

      for (final interceptor in config.requestInterceptors) {
        if (interceptor.matchesRequest(url, method)) {
          debugPrint('[WebView] 🎯 RequestInterceptor matched → $url');
          final result = await interceptor.handleResponse(
            url: url,
            method: method,
            statusCode: statusCode,
            body: body,
          );
          if (result != null) {
            debugPrint('[WebView] 🏁 RequestInterceptor result → $result');
            emit(
              state.copyWith(
                webViewStatus: WebViewStatus.intercepted,
                result: result,
                isLoading: false,
              ),
            );
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[WebView] ⚠️ XHR parse error → $e');
    }
  }

  void _onErrorOccurred(
    WebViewErrorOccurred event,
    Emitter<WebViewState> emit,
  ) {
    debugPrint('[WebView] ❌ Error → ${event.description}');
    emit(
      state.copyWith(
        webViewStatus: WebViewStatus.error,
        errorMessage: event.description,
        isLoading: false,
      ),
    );
  }

  void _onDismissRequested(
    WebViewDismissRequested event,
    Emitter<WebViewState> emit,
  ) {
    emit(
      state.copyWith(
        webViewStatus: WebViewStatus.intercepted,
        result: const WebViewDismissed<dynamic>(),
      ),
    );
  }
}
