import "package:solidus/solidus.dart";
import "package:web/web.dart" as web;

import "../solid_dom.dart";

/// Slider primitive (unstyled).
///
/// Uses `<input type="range">` as the semantic/control surface.
web.HTMLInputElement createSlider({
  required double Function() value,
  required void Function(double next) setValue,
  double Function()? min,
  double Function()? max,
  double Function()? step,
  bool Function()? disabled,
  String? id,
  String className = "",
  String? ariaLabel,
}) {
  final minAccessor = min ?? () => 0.0;
  final maxAccessor = max ?? () => 100.0;
  final stepAccessor = step ?? () => 1.0;
  final isDisabled = disabled ?? () => false;

  final el = web.HTMLInputElement()
    ..type = "range"
    ..id = id ?? ""
    ..className = className;

  if (ariaLabel != null && ariaLabel.isNotEmpty) {
    el.setAttribute("aria-label", ariaLabel);
  }

  void syncFromDom() {
    final next = double.tryParse(el.value);
    if (next == null) return;
    setValue(next);
  }

  createRenderEffect(() {
    final mn = minAccessor();
    final mx = maxAccessor();
    final st = stepAccessor();
    el.min = mn.toString();
    el.max = mx.toString();
    el.step = st.toString();

    final v = value().clamp(mn, mx).toDouble();
    final s = v.toString();
    if (el.value != s) el.value = s;

    // Extra attrs for styling/debugging.
    el.setAttribute("data-min", mn.toString());
    el.setAttribute("data-max", mx.toString());
    el.setAttribute("data-value", v.toString());
  });

  createRenderEffect(() {
    final d = isDisabled();
    el.disabled = d;
    if (d) {
      el.setAttribute("aria-disabled", "true");
      el.setAttribute("data-disabled", "true");
    } else {
      el.removeAttribute("aria-disabled");
      el.removeAttribute("data-disabled");
    }
  });

  on(el, "input", (_) => syncFromDom());
  on(el, "change", (_) => syncFromDom());
  return el;
}

