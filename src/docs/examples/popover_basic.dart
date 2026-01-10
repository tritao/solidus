import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsPopoverBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final lastClose = createSignal("none");

    final trigger = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Toggle popover";

    final status =
        p("", className: "muted", children: [text(() => "Last close: ${lastClose.value}")]);

    on(trigger, "click", (_) => open.value = !open.value);

    return row(children: [
      trigger,
      status,
      Popover(
        open: () => open.value,
        setOpen: (next) => open.value = next,
        anchor: trigger,
        portalId: "docs-popover-basic-portal",
        onClose: (reason) => lastClose.value = reason,
        builder: (close) {
          final panel = div(
            className: "card",
            children: [
              p("This is a popover panel."),
            ],
          )..style.maxWidth = "360px";

          final closeBtn = web.HTMLButtonElement()
            ..type = "button"
            ..className = "btn secondary"
            ..textContent = "Close";
          on(closeBtn, "click", (_) => close());
          panel.appendChild(closeBtn);
          return panel;
        },
      ),
    ]);
  });
  // #doc:endregion snippet
}
