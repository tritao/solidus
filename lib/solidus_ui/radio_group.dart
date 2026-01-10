import "package:web/web.dart" as web;

import "../solidus_dom/core/radio_group.dart";
import "../solidus_dom/selection/types.dart";

/// Styled RadioGroup (Solidus UI skin).
///
/// For an unstyled primitive, use `createRadioGroup` from `solid_dom`.
web.HTMLElement RadioGroup({
  required Iterable<RadioGroupItem> items,
  required String? Function() value,
  required void Function(String next) setValue,
  Orientation Function()? orientation,
  bool Function()? shouldFocusWrap,
  bool Function()? disabled,
  String? ariaLabel,
  String? id,
  String rootClassName = "radioGroup",
  String itemClassName = "radioItem",
}) {
  return createRadioGroup(
    items: items,
    value: value,
    setValue: setValue,
    orientation: orientation,
    shouldFocusWrap: shouldFocusWrap,
    disabled: disabled,
    ariaLabel: ariaLabel,
    id: id,
    rootClassName: rootClassName,
    itemClassName: itemClassName,
  );
}
