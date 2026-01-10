import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsSpinnerBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final row = web.HTMLDivElement()..className = "row";
    row.appendChild(Spinner(ariaLabel: "Loading"));
    row.appendChild(web.HTMLSpanElement()..className = "muted"..textContent = "Loading…");
    return row;
  });
  // #doc:endregion snippet
}
