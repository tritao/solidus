import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

final _NameContext = createContext<String>("(default)");

Dispose mountDocsRuntimeContextBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    web.HTMLElement renderReader(String label) {
      return p(
        "",
        className: "muted",
        children: [text(() => "$label: ${useContext(_NameContext)}")],
      );
    }

    final outside = renderReader("Outside provider");

    final card = div(className: "card");
    provideContext<String, void>(_NameContext, "provided", () {
      card.appendChild(renderReader("Inside provider"));
    });

    return div(children: [outside, card]);
  });
  // #doc:endregion snippet
}
