import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsScrollAreaBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final area = ScrollArea();
    for (var i = 1; i <= 50; i++) {
      area.content.appendChild(web.HTMLDivElement()
        ..textContent = "Item $i"
        ..style.padding = "6px 0");
    }
    return area.root;
  });
  // #doc:endregion snippet
}

