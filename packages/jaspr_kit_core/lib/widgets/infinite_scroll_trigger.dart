import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

/// Calls [onVisible] when this element comes within [rootMargin] of the
/// viewport — the web way to drive infinite scroll (an `IntersectionObserver`,
/// no scroll listeners, works with any layout).
///
/// Place it after the last list item. Pass something that changes after every
/// page load as [watch] (e.g. `items.length`): the observer is re-armed then,
/// so if the trigger is *still* visible (short pages, tall screens) the next
/// page is requested immediately instead of waiting for a scroll.
///
/// Pairs with `PaginatedBloc` (kit_core): `onVisible: () => bloc.add(LoadMore())`
/// — the mixin already ignores duplicate / in-flight requests.
class InfiniteScrollTrigger extends StatefulComponent {
  const InfiniteScrollTrigger({
    required this.onVisible,
    required this.watch,
    this.enabled = true,
    this.rootMargin = '600px',
    this.child,
    super.key,
  });

  final void Function() onVisible;
  final Object? watch;
  final bool enabled;

  /// How early to trigger, as a CSS margin around the viewport.
  final String rootMargin;

  /// Usually a "loading more…" indicator.
  final Component? child;

  @override
  State<InfiniteScrollTrigger> createState() => _InfiniteScrollTriggerState();
}

class _InfiniteScrollTriggerState extends State<InfiniteScrollTrigger> {
  final _nodeKey = GlobalNodeKey<web.Element>();
  web.IntersectionObserver? _observer;

  @override
  void initState() {
    super.initState();
    _scheduleObserve();
  }

  @override
  void didUpdateComponent(InfiniteScrollTrigger oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.watch != component.watch ||
        oldComponent.enabled != component.enabled ||
        oldComponent.rootMargin != component.rootMargin) {
      _scheduleObserve();
    }
  }

  /// After the frame, so the element is in the DOM with its final layout.
  void _scheduleObserve() {
    if (!kIsWeb) return;
    context.binding.addPostFrameCallback(_observe);
  }

  void _observe() {
    _disconnect();
    if (!mounted || !component.enabled) return;
    final node = _nodeKey.currentNode;
    if (node == null) return;

    final observer = web.IntersectionObserver(
      ((
            JSArray<web.IntersectionObserverEntry> entries,
            web.IntersectionObserver _,
          ) {
            if (!mounted || !component.enabled) return;
            if (entries.toDart.any((e) => e.isIntersecting)) {
              component.onVisible();
            }
          })
          .toJS,
      web.IntersectionObserverInit(rootMargin: component.rootMargin),
    );
    // observe() reports the current state immediately — that is what lets a
    // re-arm after each page load continue filling a tall screen.
    observer.observe(node);
    _observer = observer;
  }

  void _disconnect() {
    _observer?.disconnect();
    _observer = null;
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div(
      key: _nodeKey,
      classes: 'kit-infinite-trigger',
      attributes: const {'aria-hidden': 'true'},
      [?component.child],
    );
  }
}
