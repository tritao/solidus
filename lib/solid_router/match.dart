final class RouteDef {
  RouteDef({
    this.path,
    this.index = false,
    required this.view,
    this.children = const <RouteDef>[],
  }) : assert(
          !index || (path == null || path == ""),
          "Index routes must not define a path.",
        );

  /// Path pattern for this route.
  ///
  /// - `null`: pathless layout route (matches without consuming segments)
  /// - `""` or `"/"`: matches the current segment boundary (consumes 0)
  /// - literals: `/users`
  /// - params: `/users/:id`
  /// - splat: `*` or `/files/*` (captures remaining segments as `splat`)
  ///
  /// For nested routes, paths are matched relative to the parent unless they
  /// start with `/`, in which case they are treated as absolute from the root.
  final String? path;

  /// Index routes match only when all segments are consumed.
  final bool index;

  /// Called when this route is the best match for the current location.
  ///
  /// This file keeps the type as `Object?` to avoid depending on DOM types.
  final Object? Function(RouteMatch match) view;

  final List<RouteDef> children;
}

final class RouteMatch {
  RouteMatch({
    required this.route,
    required this.params,
    required this.matchedPath,
  });

  final RouteDef route;

  /// Merged params from root → this match.
  final Map<String, String> params;

  /// The matched path prefix (always begins with `/`).
  final String matchedPath;
}

List<RouteMatch> matchRoutes(
  List<RouteDef> routes,
  String pathname,
) {
  final segments = _splitPath(pathname);
  final matches = _matchList(
    routes: routes,
    segments: segments,
    startIndex: 0,
    paramsSoFar: const <String, String>{},
    matchedSegments: const <String>[],
  );
  return matches ?? const <RouteMatch>[];
}

List<RouteMatch>? _matchList({
  required List<RouteDef> routes,
  required List<String> segments,
  required int startIndex,
  required Map<String, String> paramsSoFar,
  required List<String> matchedSegments,
}) {
  for (final route in routes) {
    final isAbsolute = route.path?.startsWith("/") ?? false;
    final index = isAbsolute ? 0 : startIndex;
    final baseMatched = isAbsolute ? const <String>[] : matchedSegments;

    if (route.index) {
      if (index != segments.length) continue;
      return <RouteMatch>[
        RouteMatch(
          route: route,
          params: Map<String, String>.unmodifiable(paramsSoFar),
          matchedPath: _joinPath(baseMatched),
        ),
      ];
    }

    final result = _matchPath(route.path, segments, index);
    if (result == null) continue;

    final nextParams = <String, String>{...paramsSoFar, ...result.params};
    final nextMatchedSegments = <String>[
      ...baseMatched,
      ...result.matchedSegments,
    ];
    final match = RouteMatch(
      route: route,
      params: Map<String, String>.unmodifiable(nextParams),
      matchedPath: _joinPath(nextMatchedSegments),
    );

    final nextIndex = result.nextIndex;
    if (route.children.isNotEmpty) {
      final child = _matchList(
        routes: route.children,
        segments: segments,
        startIndex: nextIndex,
        paramsSoFar: nextParams,
        matchedSegments: nextMatchedSegments,
      );
      if (child != null) return <RouteMatch>[match, ...child];
    }

    if (nextIndex == segments.length) return <RouteMatch>[match];
  }

  return null;
}

final class _PathMatch {
  _PathMatch({
    required this.nextIndex,
    required this.params,
    required this.matchedSegments,
  });

  final int nextIndex;
  final Map<String, String> params;
  final List<String> matchedSegments;
}

_PathMatch? _matchPath(String? pattern, List<String> segments, int startIndex) {
  if (pattern == null) {
    return _PathMatch(
      nextIndex: startIndex,
      params: const <String, String>{},
      matchedSegments: const <String>[],
    );
  }

  if (pattern.isEmpty || pattern == "/") {
    return _PathMatch(
      nextIndex: startIndex,
      params: const <String, String>{},
      matchedSegments: const <String>[],
    );
  }

  if (pattern == "*") {
    final rest = segments.sublist(startIndex).join("/");
    return _PathMatch(
      nextIndex: segments.length,
      params: rest.isEmpty ? const <String, String>{} : <String, String>{"splat": rest},
      matchedSegments: segments.sublist(startIndex),
    );
  }

  final patSegments = _splitPath(pattern);
  final params = <String, String>{};
  final matched = <String>[];
  var i = startIndex;

  for (var j = 0; j < patSegments.length; j++) {
    final pat = patSegments[j];
    final isLast = j == patSegments.length - 1;
    if (pat == "*") {
      final rest = segments.sublist(i).join("/");
      if (rest.isNotEmpty) params["splat"] = rest;
      matched.addAll(segments.sublist(i));
      i = segments.length;
      return _PathMatch(nextIndex: i, params: params, matchedSegments: matched);
    }

    if (i >= segments.length) return null;
    final seg = segments[i];
    if (pat.startsWith(":")) {
      final name = pat.substring(1);
      if (name.isEmpty) return null;
      params[name] = seg;
      matched.add(seg);
      i++;
      continue;
    }

    if (pat != seg) return null;
    matched.add(seg);
    i++;

    if (isLast) {
      // ok
    }
  }

  return _PathMatch(nextIndex: i, params: params, matchedSegments: matched);
}

List<String> _splitPath(String path) {
  final normalized = path.startsWith("/") ? path.substring(1) : path;
  if (normalized.isEmpty) return const <String>[];
  return normalized.split("/").where((s) => s.isNotEmpty).toList(growable: false);
}

String _joinPath(List<String> segments) {
  if (segments.isEmpty) return "/";
  return "/${segments.join("/")}";
}

