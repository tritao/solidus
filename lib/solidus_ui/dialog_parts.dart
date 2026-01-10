import "package:web/web.dart" as web;

web.HTMLDivElement DialogHeader({
  String className = "dialogHeader",
  String? title,
  String? description,
}) {
  final el = web.HTMLDivElement()..className = className;
  if (title != null) {
    el.appendChild(web.HTMLHeadingElement.h2()
      ..className = "dialogTitle"
      ..textContent = title);
  }
  if (description != null) {
    el.appendChild(web.HTMLParagraphElement()
      ..className = "dialogDescription"
      ..textContent = description);
  }
  return el;
}

web.HTMLDivElement DialogFooter({
  String className = "dialogFooter",
  Iterable<web.Node> Function()? children,
}) {
  final el = web.HTMLDivElement()..className = className;
  final nodes = children?.call();
  if (nodes != null) for (final n in nodes) el.appendChild(n);
  return el;
}

