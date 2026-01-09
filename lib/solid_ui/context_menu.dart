import "package:web/web.dart" as web;

import "../solid_dom/core/context_menu.dart";
import "../solid_dom/core/menu.dart";
import "../solid_dom/focus_scope.dart";

/// ContextMenu entrypoint (Solidus UI).
///
/// Styling is determined by the elements returned by your builder (e.g.
/// `.menu`, `.menuItem` classes).
web.DocumentFragment ContextMenu({
  required bool Function() open,
  required void Function(bool next) setOpen,
  required web.Element target,
  required MenuBuilder builder,
  bool disabled = false,
  void Function(String reason)? onClose,
  void Function(FocusScopeAutoFocusEvent event)? onOpenAutoFocus,
  void Function(FocusScopeAutoFocusEvent event)? onCloseAutoFocus,
  int exitMs = 120,
  String? portalId,
}) {
  return createContextMenu(
    open: open,
    setOpen: setOpen,
    target: target,
    builder: builder,
    disabled: disabled,
    onClose: onClose,
    onOpenAutoFocus: onOpenAutoFocus,
    onCloseAutoFocus: onCloseAutoFocus,
    exitMs: exitMs,
    portalId: portalId,
  );
}
