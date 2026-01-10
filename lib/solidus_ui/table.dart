import "package:web/web.dart" as web;

web.HTMLDivElement Table({
  String wrapperClassName = "tableWrap",
  String tableClassName = "table",
  Iterable<web.Node> Function()? head,
  Iterable<web.Node> Function()? body,
}) {
  final wrap = web.HTMLDivElement()..className = wrapperClassName;
  final table = web.HTMLTableElement()..className = tableClassName;
  wrap.appendChild(table);

  final theadNodes = head?.call();
  if (theadNodes != null) {
    final t = web.document.createElement("thead") as web.HTMLTableSectionElement;
    for (final n in theadNodes) t.appendChild(n);
    table.appendChild(t);
  }

  final tbodyNodes = body?.call();
  if (tbodyNodes != null) {
    final t = web.document.createElement("tbody") as web.HTMLTableSectionElement;
    for (final n in tbodyNodes) t.appendChild(n);
    table.appendChild(t);
  }

  return wrap;
}

web.HTMLTableRowElement TableRow({Iterable<web.Node> Function()? children}) {
  final tr = web.document.createElement("tr") as web.HTMLTableRowElement;
  final nodes = children?.call();
  if (nodes != null) for (final n in nodes) tr.appendChild(n);
  return tr;
}

web.HTMLTableCellElement TableHeadCell({
  String className = "th",
  required String text,
}) {
  final th = web.document.createElement("th") as web.HTMLTableCellElement
    ..className = className
    ..textContent = text;
  return th;
}

web.HTMLTableCellElement TableCell({
  String className = "td",
  required String text,
}) {
  final td = web.document.createElement("td") as web.HTMLTableCellElement
    ..className = className
    ..textContent = text;
  return td;
}
