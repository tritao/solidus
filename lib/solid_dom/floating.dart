import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "./solid_dom.dart";

final class FloatingHandle {
  FloatingHandle._(this._dispose);
  final void Function() _dispose;
  void dispose() => _dispose();
}

void _setPx(web.HTMLElement el, String prop, double value) {
  el.style.setProperty(prop, "${value.toStringAsFixed(2)}px");
}

void _positionFixed({
  required web.Element anchor,
  required web.HTMLElement floating,
  required String placement,
  required double offset,
}) {
  final a = anchor.getBoundingClientRect();
  final f = floating.getBoundingClientRect();

  double left;
  double top;

  switch (placement) {
    case "top":
      left = a.left + (a.width - f.width) / 2;
      top = a.top - f.height - offset;
      break;
    case "top-start":
      left = a.left;
      top = a.top - f.height - offset;
      break;
    case "right-start":
      left = a.right + offset;
      top = a.top;
      break;
    case "left-start":
      left = a.left - f.width - offset;
      top = a.top;
      break;
    case "bottom":
      left = a.left + (a.width - f.width) / 2;
      top = a.bottom + offset;
      break;
    case "bottom-start":
    default:
      left = a.left;
      top = a.bottom + offset;
      break;
  }

  floating.style.position = "fixed";
  _setPx(floating, "left", left);
  _setPx(floating, "top", top);
}

FloatingHandle floatToAnchor({
  required web.Element anchor,
  required web.HTMLElement floating,
  String placement = "bottom-start",
  double offset = 8,
}) {
  var disposed = false;

  void compute() {
    if (disposed) return;
    if (!floating.isConnected) return;
    _positionFixed(
      anchor: anchor,
      floating: floating,
      placement: placement,
      offset: offset,
    );
  }

  void computeWhenConnected() {
    if (disposed) return;
    if (!floating.isConnected) {
      scheduleMicrotask(computeWhenConnected);
      return;
    }
    compute();
  }

  scheduleMicrotask(computeWhenConnected);
  on(web.window, "scroll", (_) => compute());
  on(web.window, "resize", (_) => compute());

  void dispose() {
    disposed = true;
  }

  onCleanup(dispose);
  return FloatingHandle._(dispose);
}

