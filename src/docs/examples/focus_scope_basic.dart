import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:dart_web_test/solid_dom.dart";
import "package:web/web.dart" as web;

Dispose mountDocsFocusScopeBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);

    final outside = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Outside focus target";

    final root = web.HTMLDivElement();
    final row = web.HTMLDivElement()..className = "row";
    final trigger = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Open focus scope";
    on(trigger, "click", (_) => open.value = true);
    row.appendChild(trigger);
    row.appendChild(outside);
    root.appendChild(row);

    root.appendChild(
      Presence(
        when: () => open.value,
        exitMs: 120,
        children: () => Portal(
          id: "docs-focus-scope-portal",
          children: () {
            final panel = web.HTMLDivElement()
              ..className = "card"
              ..style.maxWidth = "520px";

            panel.appendChild(
              web.HTMLHeadingElement.h2()..textContent = "Focus scope",
            );
            panel.appendChild(
              web.HTMLParagraphElement()
                ..className = "muted"
                ..textContent =
                    "Tab/Shift+Tab stays inside this panel. Escape closes it.",
            );

            final a = web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "First";
            final b = web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "Second";
            final close = web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "Close";

            on(close, "click", (_) => open.value = false);
            on(panel, "keydown", (e) {
              if (e is! web.KeyboardEvent) return;
              if (e.key == "Escape") {
                e.preventDefault();
                open.value = false;
              }
            });

            final actions = web.HTMLDivElement()..className = "row";
            actions.appendChild(a);
            actions.appendChild(b);
            actions.appendChild(close);
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

            focusScope(panel, trapFocus: true, restoreFocus: true);

            scheduleMicrotask(() {
              try {
                a.focus();
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

