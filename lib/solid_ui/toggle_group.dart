import "package:web/web.dart" as web;

import "../solid_dom/core/toggle_group.dart";
import "../solid_dom/selection/types.dart";

/// Styled ToggleGroup (Solidus UI skin).
///
/// For an unstyled primitive, use `createToggleGroup` from `solid_dom`.
web.HTMLElement ToggleGroup({
  required ToggleGroupType Function() type,
  required Iterable<ToggleGroupItem> items,
  // Single
  String? Function()? value,
  void Function(String? next)? setValue,
  // Multiple
  Set<String> Function()? values,
  void Function(Set<String> next)? setValues,
  bool Function()? disallowEmptySelection,
  bool Function()? disabled,
  Orientation Function()? orientation,
  bool Function()? shouldFocusWrap,
  String? ariaLabel,
  String? id,
  String rootClassName = "toggleGroup",
  String itemClassName = "toggleItem",
}) {
  return createToggleGroup(
    type: type,
    items: items,
    value: value,
    setValue: setValue,
    values: values,
    setValues: setValues,
    disallowEmptySelection: disallowEmptySelection,
    disabled: disabled,
    orientation: orientation,
    shouldFocusWrap: shouldFocusWrap,
    ariaLabel: ariaLabel,
    id: id,
    rootClassName: rootClassName,
    itemClassName: itemClassName,
  );
}
