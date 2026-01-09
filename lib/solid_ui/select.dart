import "package:web/web.dart" as web;

import "../solid_dom/core/select.dart";

/// Styled Select (Solidus UI skin).
///
/// For an unstyled primitive, use `createSelect` from `solid_dom`.
web.DocumentFragment Select<T>({
  required bool Function() open,
  required void Function(bool next) setOpen,
  required web.HTMLElement trigger,
  required Iterable<SelectOption<T>> Function() options,
  required T? Function() value,
  required void Function(T? next) setValue,
  void Function(String reason)? onClose,
  bool Function(T a, T b)? equals,
  String placement = "bottom-start",
  double offset = 4,
  double viewportPadding = 8,
  bool flip = true,
  double shift = 0,
  bool slide = true,
  bool overlap = false,
  bool fitViewport = true,
  bool disallowEmptySelection = false,
  int exitMs = 120,
  String? portalId,
  String? listboxId,
  SelectOptionBuilder<T>? optionBuilder,
}) {
  return createSelect(
    open: open,
    setOpen: setOpen,
    trigger: trigger,
    options: options,
    value: value,
    setValue: setValue,
    onClose: onClose,
    equals: equals,
    placement: placement,
    offset: offset,
    viewportPadding: viewportPadding,
    flip: flip,
    shift: shift,
    slide: slide,
    overlap: overlap,
    fitViewport: fitViewport,
    disallowEmptySelection: disallowEmptySelection,
    exitMs: exitMs,
    portalId: portalId,
    listboxId: listboxId,
    listboxClassName: "card listbox",
    listboxScrollClassName: "listboxScroll",
    listboxOptionClassName: "listboxOption",
    listboxSectionGroupClassName: "listboxGroup",
    listboxSectionLabelClassName: "listboxGroupLabel",
    listboxEmptyClassName: "listboxEmpty",
    optionBuilder: optionBuilder,
  );
}

