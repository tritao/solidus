import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "../solid_dom.dart";

/// Toggle primitive (unstyled).
///
/// Uses `aria-pressed` and is semantically a "toggle button".
web.HTMLButtonElement createToggle({
  required bool Function() pressed,
  required void Function(bool next) setPressed,
  bool Function()? disabled,
  String? id,
  String className = "",
  String? ariaLabel,
}) {
  final isDisabled = disabled ?? () => false;

  final btn = web.HTMLButtonElement()
    ..type = "button"
    ..id = id ?? ""
    ..className = className;

  if (ariaLabel != null && ariaLabel.isNotEmpty) {
    btn.setAttribute("aria-label", ariaLabel);
  }

  void toggle() {
    if (isDisabled()) return;
    setPressed(!pressed());
  }

  createRenderEffect(() {
    final p = pressed();
    btn.setAttribute("aria-pressed", p ? "true" : "false");
    btn.setAttribute("data-state", p ? "on" : "off");
  });

  createRenderEffect(() {
    final d = isDisabled();
    btn.disabled = d;
    if (d) {
      btn.setAttribute("aria-disabled", "true");
      btn.setAttribute("data-disabled", "true");
    } else {
      btn.removeAttribute("aria-disabled");
      btn.removeAttribute("data-disabled");
    }
  });

  on(btn, "click", (_) => toggle());
  on(btn, "keydown", (e) {
    if (e is! web.KeyboardEvent) return;
    if (e.key != "Enter" && e.key != " ") return;
    e.preventDefault();
    toggle();
  });

  return btn;
}

