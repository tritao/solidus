import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_dom.dart";
import "package:web/web.dart" as web;

Dispose mountDocsFocusScopeBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);

    final outside = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Outside focus target";

    final trigger = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Open focus scope";
    on(trigger, "click", (_) => open.value = true);

    return div(children: [
      row(children: [trigger, outside]),
      Presence(
        when: () => open.value,
        exitMs: 120,
        children: () => Portal(
          id: "docs-focus-scope-portal",
          children: () {
            final panel = div(className: "card", children: [
              h2("Focus scope"),
              p(
                "Tab/Shift+Tab stays inside this panel. Escape closes it.",
                className: "muted",
              ),
            ])..style.maxWidth = "520px";

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

            panel.appendChild(row(children: [a, b, close]));

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
    ]);
  });
  // #doc:endregion snippet
}
