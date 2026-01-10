import "package:web/web.dart" as web;

import "../solidus_dom/core/checkbox.dart";

/// Styled checkbox (Solidus UI skin).
///
/// For an unstyled primitive, use `createCheckbox` from `solid_dom`.
web.HTMLElement Checkbox({
  required bool Function() checked,
  required void Function(bool next) setChecked,
  bool Function()? indeterminate,
  void Function(bool next)? setIndeterminate,
  bool Function()? disabled,
  String? id,
  String className = "checkbox",
  String? ariaLabel,
}) {
  return createCheckbox(
    checked: checked,
    setChecked: setChecked,
    indeterminate: indeterminate,
    setIndeterminate: setIndeterminate,
    disabled: disabled,
    id: id,
    className: className,
    ariaLabel: ariaLabel,
  );
}

