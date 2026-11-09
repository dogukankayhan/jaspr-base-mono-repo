import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/webview_bloc.dart';
import '../bloc/webview_event.dart';
import '../bloc/webview_state.dart';
import '../config/webview_config.dart';
import 'app_webview.dart';

/// Full-screen WebView with an AppBar close button.
///
/// Creates and owns [WebViewBloc] at screen level so the AppBar close button
/// can add [WebViewDismissRequested] directly. A single [BlocListener] handles
/// all pops — both from interceptors and from the close button.
class WebViewScreen extends StatefulWidget {
  final WebViewConfig config;

  const WebViewScreen({super.key, required this.config});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = WebViewBloc(config: widget.config);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<WebViewBloc, WebViewState>(
        listenWhen: (prev, curr) =>
            curr.webViewStatus == WebViewStatus.intercepted &&
            curr.result != null &&
            prev.result != curr.result,
        listener: (_, state) => Navigator.of(context).pop(state.result),
        child: Scaffold(
          appBar: AppBar(
            title: widget.config.title != null
                ? Text(widget.config.title!)
                : null,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _bloc.add(const WebViewDismissRequested()),
            ),
          ),
          body: AppWebView(config: widget.config, bloc: _bloc),
        ),
      ),
    );
  }
}
