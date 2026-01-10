import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsRuntimeDomBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final items = createSignal<List<String>>(["Solid", "React"]);

    final add = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Add item";
    on(add, "click", (_) {
      final next = [...items.value];
      next.add("Item ${next.length + 1}");
      items.value = next;
    });

    final clear = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Clear";
    on(clear, "click", (_) => items.value = const []);

    final countEl =
        p("", className: "muted", children: [text(() => "count=${items.value.length}")]);

    final controls = row(children: [add, clear, countEl]);

    final listEl = ul(className: "list");
    listEl.appendChild(insert(listEl, () {
      return [
        for (final item in items.value)
          li(className: "item", text: item),
      ];
    }));

    return div(children: [controls, listEl]);
  });
  // #doc:endregion snippet
}
