import "package:web/web.dart" as web;

import "../solid_dom/core/slider.dart";

/// Styled Slider (Solidus UI skin).
web.HTMLInputElement Slider({
  required double Function() value,
  required void Function(double next) setValue,
  double Function()? min,
  double Function()? max,
  double Function()? step,
  bool Function()? disabled,
  String? id,
  String className = "slider",
  String? ariaLabel,
}) {
  return createSlider(
    value: value,
    setValue: setValue,
    min: min,
    max: max,
    step: step,
    disabled: disabled,
    id: id,
    className: className,
    ariaLabel: ariaLabel,
  );
}

