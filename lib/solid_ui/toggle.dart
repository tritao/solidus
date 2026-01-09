import "package:web/web.dart" as web;

import "../solid_dom/core/toggle.dart";

enum ToggleVariant { defaultVariant, outline }

enum ToggleSize { sm, normal, lg }

String _variantClass(ToggleVariant v) => switch (v) {
      ToggleVariant.defaultVariant => "default",
      ToggleVariant.outline => "outline",
    };

String _sizeClass(ToggleSize s) => switch (s) {
      ToggleSize.sm => "sm",
      ToggleSize.normal => "default",
      ToggleSize.lg => "lg",
    };

/// Styled Toggle (Solidus UI skin).
web.HTMLButtonElement Toggle({
  required bool Function() pressed,
  required void Function(bool next) setPressed,
  bool Function()? disabled,
  String? id,
  ToggleVariant variant = ToggleVariant.defaultVariant,
  ToggleSize size = ToggleSize.normal,
  String className = "toggle",
  String? ariaLabel,
  String? label,
}) {
  final btn = createToggle(
    pressed: pressed,
    setPressed: setPressed,
    disabled: disabled,
    id: id,
    className: className,
    ariaLabel: ariaLabel,
  );
  btn.classList.add("toggle--${_variantClass(variant)}");
  btn.classList.add("toggle--${_sizeClass(size)}");
  if (label != null) btn.textContent = label;
  return btn;
}

