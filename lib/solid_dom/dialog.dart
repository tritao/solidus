import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "./overlay.dart";
import "./presence.dart";
import "./solid_dom.dart";

typedef DialogBuilder = web.HTMLElement Function(void Function() close);

web.DocumentFragment Dialog({
  required bool Function() open,
  required void Function(bool next) setOpen,
  required DialogBuilder builder,
  void Function(String reason)? onClose,
  bool modal = true,
  int exitMs = 120,
  web.HTMLElement? initialFocus,
  String? labelledBy,
  String? describedBy,
  String role = "dialog",
  String? portalId,
}) {
  return Presence(
    when: open,
    exitMs: exitMs,
    children: () => Portal(
      id: portalId,
      children: () {
        void close([String reason = "close"]) {
          onClose?.call(reason);
          setOpen(false);
        }

        final dialog = builder(close);
        dialog.setAttribute("role", role);
        if (modal) dialog.setAttribute("aria-modal", "true");
        if (labelledBy != null) {
          dialog.setAttribute("aria-labelledby", labelledBy);
        }
        if (describedBy != null) {
          dialog.setAttribute("aria-describedby", describedBy);
        }
        dialog.tabIndex = -1;

        dismissableLayer(
          dialog,
          onDismiss: (reason) => close(reason),
        );
        focusTrap(dialog, initialFocus: initialFocus);
        if (modal) {
          scrollLock();
          ariaHideOthers(dialog);
        }

        return dialog;
      },
    ),
  );
}

