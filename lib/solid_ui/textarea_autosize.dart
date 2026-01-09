import "package:web/web.dart" as web;

import "../solid_dom/core/textarea_autosize.dart";

/// Styled autosizing Textarea (Solidus UI skin).
web.HTMLTextAreaElement TextareaAutosize({
  String? id,
  String className = "textarea",
  String? ariaLabel,
  String? placeholder,
  int? rows,
  bool Function()? disabled,
  String? Function()? value,
  void Function(String next)? setValue,
  int? maxHeightPx,
}) {
  return createTextareaAutosize(
    id: id,
    className: className,
    ariaLabel: ariaLabel,
    placeholder: placeholder,
    rows: rows,
    disabled: disabled,
    value: value,
    setValue: setValue,
    maxHeightPx: maxHeightPx,
  );
}

