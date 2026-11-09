import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bloc/webview_bloc.dart';
import '../bloc/webview_event.dart';
import '../bloc/webview_state.dart';
import '../config/webview_config.dart';
import '../model/webview_result.dart';

/// Embeddable WebView widget.
///
/// All logic lives in [WebViewBloc]. This widget maps InAppWebView callbacks
/// to events and renders state — no business logic here.
///
/// When [bloc] is omitted the widget creates and owns its own [WebViewBloc].
/// Pass an external [bloc] (from [WebViewScreen]) when the parent controls
/// the lifecycle.
class AppWebView extends StatefulWidget {
  final WebViewConfig config;
  final WebViewBloc? bloc;
  final void Function(WebViewResult<dynamic> result)? onResult;
  final Widget? loadingIndicator;

  const AppWebView({
    super.key,
    required this.config,
    this.bloc,
    this.onResult,
    this.loadingIndicator,
  });

  @override
  State<AppWebView> createState() => AppWebViewState();
}

class AppWebViewState extends State<AppWebView> {
  late final WebViewBloc _bloc;
  late final bool _ownsBloc;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? WebViewBloc(config: widget.config);
  }

  @override
  void dispose() {
    if (_ownsBloc) _bloc.close();
    super.dispose();
  }

  // ── public API ────────────────────────────────────────────────────────────

  Future<dynamic> evaluateJavascript(String code) =>
      _bloc.evaluateJavascript(code);

  Future<void> loadUrl(String url) => _bloc.loadUrl(url);

  Future<void> reload() => _bloc.reload();

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final body = BlocConsumer<WebViewBloc, WebViewState>(
      listenWhen: (prev, curr) =>
          curr.webViewStatus == WebViewStatus.intercepted &&
          curr.result != null &&
          prev.result != curr.result,
      listener: (_, state) => widget.onResult?.call(state.result!),
      builder: (_, state) => Column(
        children: [
          _ProgressBar(
            progress: state.progress,
            custom: widget.loadingIndicator,
          ),
          Expanded(child: _buildInAppWebView()),
        ],
      ),
    );

    return _ownsBloc ? BlocProvider.value(value: _bloc, child: body) : body;
  }

  Widget _buildInAppWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(widget.config.initialUrl),
        headers: widget.config.headers.isNotEmpty
            ? widget.config.headers
            : null,
      ),
      initialUserScripts: _bloc.initialUserScripts,
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: widget.config.enableJavaScript,
        userAgent: widget.config.userAgent,
        clearCache: widget.config.clearCache,
        allowsBackForwardNavigationGestures:
            widget.config.allowsBackForwardGestures,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      onWebViewCreated: (ctrl) => _bloc.add(WebViewControllerCreated(ctrl)),
      onLoadStart: (_, url) =>
          _bloc.add(WebViewPageStarted(url?.toString() ?? '')),
      onLoadStop: (_, url) =>
          _bloc.add(WebViewPageFinished(url?.toString() ?? '')),
      onProgressChanged: (_, progress) =>
          _bloc.add(WebViewProgressChanged(progress)),
      shouldOverrideUrlLoading: (_, action) async =>
          _bloc.decideNavigation(action.request.url?.toString() ?? ''),
      onReceivedError: (_, _, error) =>
          _bloc.add(WebViewErrorOccurred(error.description)),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int progress;
  final Widget? custom;

  const _ProgressBar({required this.progress, this.custom});

  @override
  Widget build(BuildContext context) {
    if (progress >= 100) return const SizedBox.shrink();
    if (custom != null) return custom!;
    return LinearProgressIndicator(
      value: progress / 100,
      minHeight: 2,
      backgroundColor: Colors.transparent,
    );
  }
}
