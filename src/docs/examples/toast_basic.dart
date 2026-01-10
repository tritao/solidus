import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsToastBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final toaster = createToaster(defaultDurationMs: 3000);
    var counter = 0;

    final btn = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Show toast";
    on(btn, "click", (_) {
      counter += 1;
      toaster.show("Toast #$counter");
    });

    return row(children: [
      btn,
      toaster.view(
        portalId: "docs-toast-basic-portal",
        viewportId: "docs-toast-basic-viewport",
      ),
    ]);
  });
  // #doc:endregion snippet
}
