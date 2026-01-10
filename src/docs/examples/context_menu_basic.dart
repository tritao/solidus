import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsContextMenuBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final lastAction = createSignal("none");

    final target = div(className: "card", children: [
      web.Text("Right-click (or long-press) in this area."),
    ])
      ..style.padding = "14px"
      ..style.maxWidth = "420px";

    MenuContent buildMenu(MenuCloseController close) {
      final menu = div(className: "card menu")..style.minWidth = "220px";

      final copy = web.HTMLButtonElement()
        ..type = "button"
        ..className = "menuItem"
        ..textContent = "Copy";
      final paste = web.HTMLButtonElement()
        ..type = "button"
        ..className = "menuItem"
        ..textContent = "Paste";

      menu.appendChild(copy);
      menu.appendChild(paste);

      return MenuContent(
        element: menu,
        items: [
          MenuItem(
            element: copy,
            key: "copy",
            onSelect: () {
              lastAction.value = "Copy";
              close.closeAll("select");
            },
          ),
          MenuItem(
            element: paste,
            key: "paste",
            onSelect: () {
              lastAction.value = "Paste";
              close.closeAll("select");
            },
          ),
        ],
      );
    }

    final status =
        p("", className: "muted", children: [text(() => "Last action: ${lastAction.value}")]);

    return div(children: [
      target,
      status,
      ContextMenu(
        open: () => open.value,
        setOpen: (next) => open.value = next,
        target: target,
        portalId: "docs-contextmenu-basic-portal",
        builder: buildMenu,
      ),
    ]);
  });
  // #doc:endregion snippet
}
