typedef JsChannelHandler = void Function(dynamic message);

class JsChannel {
  final String name;
  final JsChannelHandler handler;

  const JsChannel({required this.name, required this.handler});
}
