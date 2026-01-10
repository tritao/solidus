import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsDialogBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final lastClose = createSignal("none");

    final titleId = "docs-dialog-basic-title";
    final descId = "docs-dialog-basic-desc";

    final btn = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Open dialog";
    on(btn, "click", (_) => open.value = true);

    final status = p(
      "",
      className: "muted",
      children: [text(() => "Last close: ${lastClose.value}")],
    );

    final panelRow = row(children: [btn, status]);

    return div(children: [
      panelRow,
      Dialog(
        open: () => open.value,
        setOpen: (next) => open.value = next,
        modal: true,
        backdrop: true,
        labelledBy: titleId,
        describedBy: descId,
        onClose: (reason) => lastClose.value = reason,
        portalId: "docs-dialog-basic-portal",
        builder: (close) {
          final panel = div(className: "card")..style.maxWidth = "520px";

          panel.appendChild(h2("Dialog title", attrs: {"id": titleId}));
          panel.appendChild(
            p(
              "Tab stays inside. Escape or click outside to dismiss.",
              className: "muted",
              attrs: {"id": descId},
            ),
          );

          final closeBtn = web.HTMLButtonElement()
            ..type = "button"
            ..className = "btn secondary"
            ..textContent = "Close";
          on(closeBtn, "click", (_) {
            lastClose.value = "close";
            close();
          });
          panel.appendChild(row(children: [closeBtn]));
          return panel;
        },
      ),
    ]);
  });
  // #doc:endregion snippet
}
