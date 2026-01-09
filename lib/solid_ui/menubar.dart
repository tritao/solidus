import "package:web/web.dart" as web;

import "../solid_dom/core/menubar.dart";

/// Styled Menubar (Solidus UI skin).
web.DocumentFragment Menubar({
  required String? Function() openKey,
  required void Function(String? next) setOpenKey,
  required List<MenubarMenu> menus,
  String className = "menubar",
  String? portalId,
  void Function(String reason)? onClose,
}) {
  return createMenubar(
    openKey: openKey,
    setOpenKey: setOpenKey,
    menus: menus,
    className: className,
    portalId: portalId,
    onClose: onClose,
  );
}

