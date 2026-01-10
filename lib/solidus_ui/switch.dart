import "package:web/web.dart" as web;

import "../solidus_dom/core/switch.dart";

/// Styled switch (Solidus UI skin).
///
/// For an unstyled primitive, use `createSwitch` from `solid_dom`.
web.HTMLElement Switch({
  required bool Function() checked,
  required void Function(bool next) setChecked,
  bool Function()? disabled,
  String? id,
  String className = "switch",
  String thumbClassName = "switchThumb",
  String? ariaLabel,
}) {
  return createSwitch(
    checked: checked,
    setChecked: setChecked,
    disabled: disabled,
    id: id,
    className: className,
    thumbClassName: thumbClassName,
    ariaLabel: ariaLabel,
  );
}

