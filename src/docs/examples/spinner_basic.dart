import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsSpinnerBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    return row(children: [
      Spinner(ariaLabel: "Loading"),
      span("Loading…", className: "muted"),
    ]);
  });
  // #doc:endregion snippet
}
