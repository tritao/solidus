import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_dom.dart";
import "package:web/web.dart" as web;

Dispose mountDocsOverlayBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final lastDismiss = createSignal("none");
    final outsideClicks = createSignal(0);

    final trigger = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Open overlay";
    on(trigger, "click", (_) => open.value = true);

    final outside = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Outside action (increments)";
    on(outside, "click", (_) => outsideClicks.value++);

    final controls = row(children: [trigger, outside]);

    final status = p(
      "",
      className: "muted",
      children: [
        text(
          () =>
              "Dismiss: ${lastDismiss.value} • Outside clicks: ${outsideClicks.value}",
        ),
      ],
    );

    return div(children: [
      controls,
      status,
      Presence(
        when: () => open.value,
        exitMs: 120,
        children: () => Portal(
          id: "docs-overlay-portal",
          children: () {
            void close([String reason = "close"]) {
              lastDismiss.value = reason;
              open.value = false;
            }

            final panel = div(className: "card")..style.maxWidth = "520px";
            panel.appendChild(h2("Overlay panel"));
            panel.appendChild(
              p(
                "Escape or click outside to dismiss. Outside clicks won’t click-through.",
                className: "muted",
              ),
            );

            final closeBtn = web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "Close";
            on(closeBtn, "click", (_) => close("close"));
            panel.appendChild(row(children: [closeBtn]));

            // Center on screen to keep the example easy to see.
            final wrapper = web.HTMLDivElement()
              ..style.position = "fixed"
              ..style.inset = "0"
              ..style.display = "flex"
              ..style.alignItems = "center"
              ..style.justifyContent = "center"
              ..style.padding = "24px"
              ..style.boxSizing = "border-box";
            wrapper.appendChild(panel);

            dismissableLayer(
              panel,
              stackElement: wrapper,
              onDismiss: close,
              dismissOnFocusOutside: false,
              preventClickThrough: true,
            );

            on(panel, "keydown", (e) {
              if (e is! web.KeyboardEvent) return;
              if (e.key == "Escape") {
                e.preventDefault();
                close("escape");
              }
            });

            scheduleMicrotask(() {
              try {
                panel.focus();
              } catch (_) {}
            });

            return wrapper;
          },
        ),
      ),
    ]);
  });
  // #doc:endregion snippet
}
