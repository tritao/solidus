import "package:web/web.dart" as web;

import "../solidus_dom/core/dropdown_menu.dart";
import "../solidus_dom/core/menu.dart";
import "../solidus_dom/focus_scope.dart";

/// DropdownMenu entrypoint (Solidus UI).
///
/// Styling is determined by the elements returned by your builder (e.g.
/// `.menu`, `.menuItem` classes).
web.DocumentFragment DropdownMenu({
  required bool Function() open,
  required void Function(bool next) setOpen,
  required web.Element anchor,
  required DropdownMenuBuilder builder,
  void Function(String reason)? onClose,
  void Function(FocusScopeAutoFocusEvent event)? onOpenAutoFocus,
  void Function(FocusScopeAutoFocusEvent event)? onCloseAutoFocus,
  int exitMs = 120,
  String placement = "bottom-start",
  double offset = 4,
  double viewportPadding = 8,
  bool flip = true,
  bool modal = false,
  String? portalId,
}) {
  return createDropdownMenu(
    open: open,
    setOpen: setOpen,
    anchor: anchor,
    builder: builder,
    onClose: onClose,
    onOpenAutoFocus: onOpenAutoFocus,
    onCloseAutoFocus: onCloseAutoFocus,
    exitMs: exitMs,
    placement: placement,
    offset: offset,
    viewportPadding: viewportPadding,
    flip: flip,
    modal: modal,
    portalId: portalId,
  );
}
