import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "./match.dart";

typedef RouterDispose = void Function();

final class BrowserRouter implements Disposable {
  BrowserRouter({
    required List<RouteDef> routes,
    String basePath = "",
  })  : routes = routes,
        basePath = _normalizeBasePath(basePath),
        location = createSignal<Uri>(
          _internalFromBrowserUri(Uri.base, _normalizeBasePath(basePath)),
        ),
        matches = createSignal<List<RouteMatch>>(const <RouteMatch>[]),
        params = createSignal<Map<String, String>>(const <String, String>{}) {
    _recompute();

    final owner = getOwner();
    final popSub = web.window.onPopState.listen((_) {
      runWithOwner(owner, () {
        location.value = _internalFromBrowserUri(Uri.base, this.basePath);
        _recompute();
      });
    });
    final hashSub = web.window.onHashChange.listen((_) {
      runWithOwner(owner, () {
        location.value = _internalFromBrowserUri(Uri.base, this.basePath);
        _recompute();
      });
    });

    _disposeBrowserListeners = () {
      // ignore: discarded_futures
      popSub.cancel();
      // ignore: discarded_futures
      hashSub.cancel();
    };
  }

  final List<RouteDef> routes;

  /// Base path prefix for deployments under a subpath (e.g. `/my-app`).
  ///
  /// This is stripped from `location` for matching, and automatically re-added
  /// when generating `href`s and calling `navigate()`.
  final String basePath;

  /// Internal location (basePath-stripped) used for matching.
  final Signal<Uri> location;

  /// Current match chain (root → leaf).
  final Signal<List<RouteMatch>> matches;

  /// Merged params (root → leaf).
  final Signal<Map<String, String>> params;

  RouterDispose? _disposeBrowserListeners;
  bool _disposed = false;

  String href(String to) {
    final internal = resolve(to);
    final browser = _browserFromInternalUri(internal, basePath);
    return _formatForHistory(browser);
  }

  Uri resolve(String to) {
    final current = location.value;
    final parsed = Uri.tryParse(to);
    if (parsed == null) return current;

    if (to.startsWith("?")) {
      return current.replace(
        query: parsed.query,
        fragment: parsed.hasFragment ? parsed.fragment : current.fragment,
      );
    }

    if (to.startsWith("#")) {
      return current.replace(fragment: parsed.fragment);
    }

    if (to.startsWith("/")) {
      return Uri(
        path: _normalizePath(parsed.path),
        query: parsed.hasQuery ? parsed.query : null,
        fragment: parsed.hasFragment ? parsed.fragment : null,
      );
    }

    if (parsed.path.isEmpty) {
      return current.replace(
        query: parsed.hasQuery ? parsed.query : null,
        fragment: parsed.hasFragment ? parsed.fragment : null,
      );
    }

    final nextPath = _resolveRelativePath(current.path, parsed.path);
    return Uri(
      path: nextPath,
      query: parsed.hasQuery ? parsed.query : null,
      fragment: parsed.hasFragment ? parsed.fragment : null,
    );
  }

  void navigate(String to, {bool replace = false}) {
    if (_disposed) return;

    final internal = resolve(to);
    final browser = _browserFromInternalUri(internal, basePath);
    final url = _formatForHistory(browser);

    if (replace) {
      web.window.history.replaceState(null, "", url);
    } else {
      web.window.history.pushState(null, "", url);
    }

    location.value = internal;
    _recompute();
  }

  void _recompute() {
    final path = location.value.path;
    final nextMatches = matchRoutes(routes, path);
    final currentMatches = matches.value;
    if (_sameMatches(currentMatches, nextMatches)) return;

    matches.value = nextMatches;
    params.value = nextMatches.isEmpty ? const <String, String>{} : nextMatches.last.params;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _disposeBrowserListeners?.call();
    _disposeBrowserListeners = null;
  }
}

String _normalizePath(String path) {
  if (path.isEmpty) return "/";
  return path.startsWith("/") ? path : "/$path";
}

String _resolveRelativePath(String basePath, String relPath) {
  final base = _splitPath(_normalizePath(basePath));
  // Treat base as a "file" path unless it ends with a slash.
  final baseIsDir = basePath.endsWith("/");
  final stack = <String>[...base];
  if (!baseIsDir && stack.isNotEmpty) {
    stack.removeLast();
  }

  for (final seg in _splitPath(relPath)) {
    if (seg == "." || seg.isEmpty) continue;
    if (seg == "..") {
      if (stack.isNotEmpty) stack.removeLast();
      continue;
    }
    stack.add(seg);
  }

  return stack.isEmpty ? "/" : "/${stack.join("/")}";
}

List<String> _splitPath(String path) {
  final normalized = path.startsWith("/") ? path.substring(1) : path;
  if (normalized.isEmpty) return const <String>[];
  return normalized.split("/").where((s) => s.isNotEmpty).toList(growable: false);
}

String _normalizeBasePath(String basePath) {
  var p = basePath.trim();
  if (p.isEmpty || p == "/") return "";
  if (!p.startsWith("/")) p = "/$p";
  while (p.endsWith("/")) {
    p = p.substring(0, p.length - 1);
  }
  return p == "/" ? "" : p;
}

Uri _internalFromBrowserUri(Uri browser, String basePath) {
  final stripped = Uri(
    path: browser.path,
    query: browser.hasQuery ? browser.query : null,
    fragment: browser.hasFragment ? browser.fragment : null,
  );

  final p = stripped.path;
  if (basePath.isEmpty) return stripped;

  if (p == basePath) {
    return stripped.replace(path: "/");
  }
  if (p.startsWith("$basePath/")) {
    final next = p.substring(basePath.length);
    return stripped.replace(path: next.isEmpty ? "/" : next);
  }

  // Best-effort: if the current URL isn't under basePath, don't strip.
  return stripped;
}

Uri _browserFromInternalUri(Uri internal, String basePath) {
  if (basePath.isEmpty) return internal;
  final p = _normalizePath(internal.path);
  final nextPath = p == "/" ? basePath : "$basePath$p";
  return internal.replace(path: nextPath);
}

String _formatForHistory(Uri uri) {
  final path = uri.path.isEmpty ? "/" : uri.path;
  final q = uri.hasQuery ? "?${uri.query}" : "";
  final f = uri.hasFragment ? "#${uri.fragment}" : "";
  return "$path$q$f";
}

bool _sameMatches(List<RouteMatch> a, List<RouteMatch> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final ma = a[i];
    final mb = b[i];
    if (!identical(ma.route, mb.route)) return false;
    if (ma.matchedPath != mb.matchedPath) return false;
    if (!_sameStringMap(ma.params, mb.params)) return false;
  }
  return true;
}

bool _sameStringMap(Map<String, String> a, Map<String, String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
