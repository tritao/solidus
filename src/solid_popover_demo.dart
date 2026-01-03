import "package:dart_web_test/solid.dart";
import "package:dart_web_test/solid_dom.dart";
import "package:web/web.dart" as web;

void mountSolidPopoverDemo(web.Element mount) {
  render(mount, () {
    final root = web.HTMLDivElement()
      ..id = "popover-root"
      ..className = "container";

    // Ensure the page can scroll so we can validate repositioning on scroll.
    root.style.minHeight = "2000px";

    final open = createSignal(false);
    final lastDismiss = createSignal("none");

    root.appendChild(web.HTMLHeadingElement.h1()..textContent = "Solid Popover Demo");

    final trigger = web.HTMLButtonElement()
      ..id = "popover-trigger"
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Toggle popover";
    on(trigger, "click", (_) => open.value = !open.value);
    root.appendChild(trigger);

    final status = web.HTMLParagraphElement()
      ..id = "popover-status"
      ..className = "muted";
    status.appendChild(text(() => "Dismiss: ${lastDismiss.value}"));
    root.appendChild(status);

    root.appendChild(
      Popover(
        open: () => open.value,
        setOpen: (next) => open.value = next,
        portalId: "popover-portal",
        anchor: trigger,
        placement: "bottom-start",
        offset: 8,
        onClose: (reason) => lastDismiss.value = reason,
        builder: (close) {
          final panel = web.HTMLDivElement()
            ..id = "popover-panel"
            ..className = "card";
          panel.appendChild(web.HTMLParagraphElement()
            ..textContent = "Popover content");
          final closeBtn = web.HTMLButtonElement()
            ..id = "popover-close"
            ..type = "button"
            ..className = "btn secondary"
            ..textContent = "Close";
          on(closeBtn, "click", (_) => close());
          panel.appendChild(closeBtn);
          return panel;
        },
      ),
    );

    return root;
  });
}
