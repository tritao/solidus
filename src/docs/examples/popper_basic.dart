import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_dom.dart";
import "package:web/web.dart" as web;

Dispose mountDocsPopperBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);

    final anchor = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Toggle popper";
    on(anchor, "click", (_) => open.value = !open.value);

    return div(className: "docPopperExample", children: [
      anchor,
      Presence(
        when: () => open.value,
        exitMs: 120,
        children: () => Portal(
          id: "docs-popper-portal",
          children: () {
            final panel = div(
              className: "card",
              attrs: {"id": "docs-popper-panel"},
              children: [
                p(
                  "I’m positioned with attachPopper().",
                  className: "muted",
                ),
              ],
            )..style.maxWidth = "360px";

            final arrow = div(className: "popperArrow")
              ..setAttribute("data-solidus-popper-arrow", "1");
            panel.appendChild(arrow);

            final handle = attachPopper(
              anchor: anchor,
              floating: panel,
              placement: "bottom-start",
              flip: true,
              slide: true,
              overlap: false,
              offset: 8,
            );
            scheduleMicrotask(handle.update);

            dismissableLayer(
              panel,
              onDismiss: (_) => open.value = false,
              dismissOnFocusOutside: false,
            );

            on(panel, "keydown", (e) {
              if (e is! web.KeyboardEvent) return;
              if (e.key == "Escape") {
                e.preventDefault();
                open.value = false;
              }
            });

            scheduleMicrotask(() {
              try {
                panel.focus();
              } catch (_) {}
            });

            return panel;
          },
        ),
      ),
    ]);
  });
  // #doc:endregion snippet
}
