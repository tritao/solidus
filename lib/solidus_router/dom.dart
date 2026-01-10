import "dart:js_interop";

import "package:solidus/solidus.dart";
import "package:web/web.dart" as web;

import "./browser.dart";
import "./match.dart";

typedef RouteOutlet = Object? Function();

final _routerContext = createContext<BrowserRouter?>(null);
final _routeMatchContext = createContext<RouteMatch?>(null);
final _outletContext = createContext<RouteOutlet>(() => null);

BrowserRouter useRouter() {
  final router = useContext(_routerContext);
  if (router == null) {
    throw StateError("useRouter() must be used under RouterProvider()");
  }
  return router;
}

Signal<Uri> useLocation() => useRouter().location;

Signal<List<RouteMatch>> useMatches() => useRouter().matches;

RouteMatch useRouteMatch() {
  final match = useContext(_routeMatchContext);
  if (match == null) {
    throw StateError("useRouteMatch() must be used under Routes()");
  }
  return match;
}

final class RouteParams {
  RouteParams._(this._router);
  final BrowserRouter _router;

  String? operator [](String key) => _router.params.value[key];

  Map<String, String> toMap() => _router.params.value;
}

RouteParams useParams() => RouteParams._(useRouter());

final class SearchParams {
  SearchParams._(this._router);
  final BrowserRouter _router;

  String? operator [](String key) => _router.location.value.queryParameters[key];

  Map<String, String> toMap() => _router.location.value.queryParameters;

  void set(String key, String? value, {bool replace = true}) {
    final uri = _router.location.value;
    final next = Map<String, String>.from(uri.queryParameters);
    if (value == null) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    final updated = uri.replace(queryParameters: next.isEmpty ? null : next);
    _router.navigate(updated.toString(), replace: replace);
  }
}

SearchParams useSearchParams() => SearchParams._(useRouter());

typedef NavigateFn = void Function(String to, {bool replace});

NavigateFn useNavigate() {
  final router = useRouter();
  return (String to, {bool replace = false}) => router.navigate(to, replace: replace);
}

R RouterProvider<R>({
  required BrowserRouter router,
  required R Function() children,
}) =>
    provideContext(_routerContext, router, children);

Object? Outlet() => useContext(_outletContext)();

web.DocumentFragment Routes({
  Object? Function()? fallback,
}) {
  final router = useRouter();
  final start = web.Comment("solid:routes-start");
  final end = web.Comment("solid:routes-end");
  final fragment = web.DocumentFragment()
    ..appendChild(start)
    ..appendChild(end);

  Dispose? disposeSubtree;
  final current = <web.Node>[];
  var mountedKind = "";

  void clear() {
    for (final node in current) {
      _detach(node);
    }
    current.clear();
    disposeSubtree?.call();
    disposeSubtree = null;
    mountedKind = "";
  }

  void mount(RouteOutlet builder, String kind) {
    clear();
    mountedKind = kind;
    createChildRoot<void>((dispose) {
      disposeSubtree = dispose;
      final built = untrack(builder);
      final nodes = _normalizeToNodes(built);
      current.addAll(nodes);
      _appendBefore(end, nodes);
    });
  }

  Object? buildMatches(List<RouteMatch> matches) {
    Object? buildAt(int i) {
      if (i >= matches.length) return null;
      final match = matches[i];
      final outlet = () => buildAt(i + 1);
      return provideContext(_routeMatchContext, match, () {
        return provideContext(_outletContext, outlet, () {
          return match.route.view(match);
        });
      });
    }

    return buildAt(0);
  }

  createRenderEffect(() {
    final matches = router.matches.value;
    if (matches.isEmpty) {
      if (fallback != null) {
        if (mountedKind != "fallback") mount(fallback, "fallback");
        return;
      }
      if (mountedKind.isNotEmpty) clear();
      return;
    }

    mount(() => buildMatches(matches), "routes");
  });

  onCleanup(() {
    clear();
    _detach(start);
    _detach(end);
  });

  return fragment;
}

web.HTMLAnchorElement Link({
  String? to,
  String Function()? toFn,
  bool replace = false,
  String? className,
  String? target,
  String? rel,
  Map<String, String>? attrs,
  Object? child,
  void Function(web.MouseEvent event)? onClick,
}) {
  assert((to == null) != (toFn == null), "Provide exactly one of to or toFn.");

  final router = useRouter();
  final a = web.HTMLAnchorElement();
  if (className != null) a.className = className;
  if (target != null) a.target = target;
  if (rel != null) a.rel = rel;
  if (attrs != null) {
    for (final entry in attrs.entries) {
      a.setAttribute(entry.key, entry.value);
    }
  }

  void setHref(String nextTo) {
    if (_isProbablyExternal(nextTo)) {
      a.setAttribute("href", nextTo);
      return;
    }
    a.setAttribute("href", router.href(nextTo));
  }

  if (to != null) {
    setHref(to);
  } else {
    createRenderEffect(() {
      setHref(toFn!());
    });
  }

  if (child != null) {
    final nodes = _normalizeToNodes(child);
    for (final node in nodes) {
      a.appendChild(node);
    }
  }

  final owner = getOwner();
  final jsHandler = ((web.Event e) {
    if (e is! web.MouseEvent) return;
    runWithOwner(owner, () {
      if (onClick != null) onClick(e);
      if (e.defaultPrevented) return;
      if (!_shouldInterceptClick(a, e)) return;

      final dest = toFn != null ? toFn() : (to as String);
      if (_isProbablyExternal(dest)) return;

      e.preventDefault();
      router.navigate(dest, replace: replace);
    });
  }).toJS;

  a.addEventListener("click", jsHandler);
  untrack(() {
    onCleanup(() => a.removeEventListener("click", jsHandler));
  });

  return a;
}

bool _shouldInterceptClick(web.HTMLAnchorElement a, web.MouseEvent e) {
  if (e.button != 0) return false;
  if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return false;
  final target = a.target;
  if (target.isNotEmpty && target != "_self") return false;
  return true;
}

bool _isProbablyExternal(String to) {
  if (to.startsWith("//")) return true;
  final uri = Uri.tryParse(to);
  if (uri == null) return false;
  return uri.hasScheme && uri.scheme.isNotEmpty;
}

void _appendBefore(web.Comment end, Iterable<web.Node> nodes) {
  if (end.parentNode == null) return;
  for (final node in nodes) {
    end.before(node as JSAny);
  }
}

List<web.Node> _normalizeToNodes(Object? value) {
  if (value == null) return const <web.Node>[];
  if (value is Iterable) {
    final out = <web.Node>[];
    for (final v in value) {
      out.addAll(_normalizeToNodes(v));
    }
    return out;
  }
  if (value is Object && _isDomNode(value)) return <web.Node>[value as web.Node];
  if (value is String || value is num || value is bool) {
    return <web.Node>[web.Text(value.toString())];
  }
  throw ArgumentError.value(
    value,
    "value",
    "Expected null, String/num/bool, Node, or Iterable<Node>",
  );
}

bool _isDomNode(Object value) {
  if (value is! web.Node) return false;
  try {
    return value.nodeType > 0;
  } catch (_) {
    return false;
  }
}

void _detach(web.Node node) {
  final parent = node.parentNode;
  if (parent == null) return;
  parent.removeChild(node);
}
