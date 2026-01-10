import "package:web/web.dart" as web;

/// Styled Card (Solidus UI skin).
web.HTMLDivElement Card({
  String className = "card",
  Iterable<web.Node> Function()? children,
}) {
  final el = web.HTMLDivElement()..className = className;
  final nodes = children?.call();
  if (nodes != null) {
    for (final n in nodes) el.appendChild(n);
  }
  return el;
}

web.HTMLDivElement CardHeader({
  String className = "cardHeader",
  Iterable<web.Node> Function()? children,
}) {
  final el = web.HTMLDivElement()..className = className;
  final nodes = children?.call();
  if (nodes != null) for (final n in nodes) el.appendChild(n);
  return el;
}

web.HTMLDivElement CardContent({
  String className = "cardContent",
  Iterable<web.Node> Function()? children,
}) {
  final el = web.HTMLDivElement()..className = className;
  final nodes = children?.call();
  if (nodes != null) for (final n in nodes) el.appendChild(n);
  return el;
}

web.HTMLDivElement CardFooter({
  String className = "cardFooter",
  Iterable<web.Node> Function()? children,
}) {
  final el = web.HTMLDivElement()..className = className;
  final nodes = children?.call();
  if (nodes != null) for (final n in nodes) el.appendChild(n);
  return el;
}

