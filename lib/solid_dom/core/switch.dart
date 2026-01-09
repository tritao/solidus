import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "../solid_dom.dart";

/// Switch primitive (unstyled).
///
/// - Uses `role="switch"` + `aria-checked`.
/// - Keyboard: Enter/Space toggles.
/// - Click toggles.
web.HTMLElement createSwitch({
  required bool Function() checked,
  required void Function(bool next) setChecked,
  bool Function()? disabled,
  String? id,
  String className = "",
  String thumbClassName = "",
  String? ariaLabel,
}) {
  final isDisabled = disabled ?? () => false;

  final root = web.HTMLButtonElement()
    ..type = "button"
    ..id = id ?? ""
    ..className = className
    ..setAttribute("role", "switch");

  if (ariaLabel != null && ariaLabel.isNotEmpty) {
    root.setAttribute("aria-label", ariaLabel);
  }

  final thumb = web.HTMLSpanElement()..className = thumbClassName;
  root.appendChild(thumb);

  void toggle() {
    if (isDisabled()) return;
    setChecked(!checked());
  }

  createRenderEffect(() {
    final v = checked();
    root.setAttribute("aria-checked", v ? "true" : "false");
    root.setAttribute("data-state", v ? "checked" : "unchecked");
  });

  createRenderEffect(() {
    final d = isDisabled();
    if (d) {
      root.disabled = true;
      root.setAttribute("aria-disabled", "true");
      root.setAttribute("data-disabled", "true");
    } else {
      root.disabled = false;
      root.removeAttribute("aria-disabled");
      root.removeAttribute("data-disabled");
    }
  });

  on(root, "click", (_) => toggle());
  on(root, "keydown", (e) {
    if (e is! web.KeyboardEvent) return;
    if (e.key != "Enter" && e.key != " ") return;
    e.preventDefault();
    toggle();
  });

  return root;
}

