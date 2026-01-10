import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_dom.dart";
import "package:web/web.dart" as web;

Dispose mountDocsInteractOutsideBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final outsideClicks = createSignal(0);
    final lastDismiss = createSignal("none");

    final row = web.HTMLDivElement()..className = "row";
    final trigger = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Open layer";
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
          id: "docs-interact-outside-portal",
          children: () {
            void close([String reason = "close"]) {
              lastDismiss.value = reason;
              open.value = false;
            }

            final panel = web.HTMLDivElement()
              ..className = "card"
              ..style.maxWidth = "520px";
            panel.appendChild(
              web.HTMLHeadingElement.h2()..textContent = "Dismissable layer",
            );
            panel.appendChild(
              web.HTMLParagraphElement()
                ..className = "muted"
                ..textContent =
                    "Click outside to dismiss. The underlying outside button should not activate on the same click.",
            );
            final closeBtn = web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "Close";
            on(closeBtn, "click", (_) => close("close"));
            final actions = web.HTMLDivElement()..className = "row";
            actions.appendChild(closeBtn);
            panel.appendChild(actions);

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

