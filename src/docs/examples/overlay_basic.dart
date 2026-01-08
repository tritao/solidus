import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:dart_web_test/solid_dom.dart";
import "package:web/web.dart" as web;

Dispose mountDocsOverlayBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final lastDismiss = createSignal("none");
    final outsideClicks = createSignal(0);

    final row = web.HTMLDivElement()..className = "row";
    final trigger = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Open overlay";
    on(trigger, "click", (_) => open.value = true);
    row.appendChild(trigger);

    final outside = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Outside action (increments)";
    on(outside, "click", (_) => outsideClicks.value++);
    row.appendChild(outside);

    final status = web.HTMLParagraphElement()..className = "muted";
    status.appendChild(
      text(
        () =>
            "Dismiss: ${lastDismiss.value} • Outside clicks: ${outsideClicks.value}",
      ),
    );

    final root = web.HTMLDivElement();
    root.appendChild(row);
    root.appendChild(status);

    root.appendChild(
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

            final panel = web.HTMLDivElement()
              ..className = "card"
              ..style.maxWidth = "520px";
            panel.appendChild(web.HTMLHeadingElement.h2()
              ..textContent = "Overlay panel");
            panel.appendChild(web.HTMLParagraphElement()
              ..className = "muted"
              ..textContent =
                  "Escape or click outside to dismiss. Outside clicks won’t click-through.");

            final closeBtn = web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "Close";
            on(closeBtn, "click", (_) => close("close"));
            final actions = web.HTMLDivElement()..className = "row";
            actions.appendChild(closeBtn);
            panel.appendChild(actions);

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
    );

    return root;
  });
  // #doc:endregion snippet
}

