import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsRuntimeReactivityBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final count = createSignal(0);
    final doubled = createMemo(() => count.value * 2);

    final inc = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Increment";
    on(inc, "click", (_) => count.value++);

    final dec = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Decrement";
    on(dec, "click", (_) => count.value--);

    final status = p(
      "",
      className: "muted",
      children: [text(() => "count=${count.value} • doubled=${doubled.value}")],
    );

    return row(children: [inc, dec, status]);
  });
  // #doc:endregion snippet
}
