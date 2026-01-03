import "dart:async";
import "dart:js_interop";

import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

final class FocusScopeHandle {
  FocusScopeHandle._(this._dispose);
  final void Function() _dispose;
  void dispose() => _dispose();
}

final class _FocusScopeEntry {
  _FocusScopeEntry(this.container);
  final web.Element container;
  bool paused = false;
  bool disposed = false;

  web.HTMLElement? previouslyFocused;
  web.HTMLElement? lastFocusedWithin;

  web.HTMLElement? startSentinel;
  web.HTMLElement? endSentinel;
}

final List<_FocusScopeEntry> _focusScopeStack = <_FocusScopeEntry>[];

bool _isTopMostScope(_FocusScopeEntry entry) =>
    _focusScopeStack.isNotEmpty && identical(_focusScopeStack.last, entry);

void _pausePreviousScope() {
  if (_focusScopeStack.isEmpty) return;
  _focusScopeStack.last.paused = true;
}

void _resumeTopScope() {
  if (_focusScopeStack.isEmpty) return;
  _focusScopeStack.last.paused = false;
}

List<web.HTMLElement> _tabbablesWithin(web.Element root) {
  final nodes = root.querySelectorAll(
    'a[href],button,input,select,textarea,[tabindex]:not([tabindex="-1"])',
  );
  final out = <web.HTMLElement>[];
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes.item(i);
    if (n == null || n is! web.HTMLElement) continue;
    if (n.getAttribute("data-solid-focus-sentinel") != null) continue;
    final disabled = (n is web.HTMLButtonElement && n.disabled) ||
        (n is web.HTMLInputElement && n.disabled) ||
        (n is web.HTMLSelectElement && n.disabled) ||
        (n is web.HTMLTextAreaElement && n.disabled);
    if (disabled) continue;
    if (n.tabIndex < 0) continue;
    out.add(n);
  }
  return out;
}

web.HTMLElement _createSentinel() {
  final el = web.HTMLSpanElement()
    ..setAttribute("data-solid-focus-sentinel", "1")
    ..tabIndex = 0;
  final style = el.style;
  style.position = "fixed";
  style.width = "1px";
  style.height = "1px";
  style.padding = "0";
  style.margin = "-1px";
  style.overflow = "hidden";
  style.clip = "rect(0, 0, 0, 0)";
  style.whiteSpace = "nowrap";
  style.border = "0";
  return el;
}

void _focusElement(web.HTMLElement? el) {
  if (el == null) return;
  try {
    el.focus();
  } catch (_) {}
}

bool _isLikelyFocusableOutside(web.Element container) {
  final active = web.document.activeElement;
  if (active is! web.HTMLElement) return false;
  if (active == web.document.body) return false;
  if (container.contains(active)) return false;
  // If something else is already focused, don't steal focus back on unmount.
  return true;
}

FocusScopeHandle focusScope(
  web.Element container, {
  bool trapFocus = false,
  web.HTMLElement? initialFocus,
  bool restoreFocus = true,

  /// Return true to prevent the default auto-focus behavior.
  bool Function()? onMountAutoFocus,

  /// Return true to prevent the default restore-focus behavior.
  bool Function()? onUnmountAutoFocus,
}) {
  final entry = _FocusScopeEntry(container);
  entry.previouslyFocused = web.document.activeElement is web.HTMLElement
      ? web.document.activeElement as web.HTMLElement
      : null;

  _pausePreviousScope();
  _focusScopeStack.add(entry);

  final start = _createSentinel();
  final end = _createSentinel();
  entry.startSentinel = start;
  entry.endSentinel = end;

  void attachSentinelsWhenConnected() {
    if (entry.disposed) return;
    if (!container.isConnected) {
      scheduleMicrotask(attachSentinelsWhenConnected);
      return;
    }
    final first = container.firstChild;
    if (first != null) {
      container.insertBefore(start, first);
    } else {
      container.appendChild(start);
    }
    container.appendChild(end);
  }

  scheduleMicrotask(attachSentinelsWhenConnected);

  void focusInitial() {
    if (entry.disposed) return;
    if (onMountAutoFocus?.call() == true) return;
    if (initialFocus != null) {
      _focusElement(initialFocus);
      return;
    }
    final tabbables = _tabbablesWithin(container);
    if (tabbables.isNotEmpty) {
      _focusElement(tabbables.first);
      return;
    }
    if (container is web.HTMLElement) _focusElement(container);
  }

  scheduleMicrotask(() {
    if (entry.disposed) return;
    if (!container.isConnected) return;
    final active = web.document.activeElement;
    if (active is web.Node && container.contains(active)) return;
    focusInitial();
  });

  void onContainerFocusIn(web.Event e) {
    if (entry.disposed) return;
    if (entry.paused) return;
    final target = e.target;
    if (target is! web.HTMLElement) return;
    if (!container.contains(target)) return;
    if (target.getAttribute("data-solid-focus-sentinel") != null) return;
    entry.lastFocusedWithin = target;
  }

  void onStartSentinelFocus(web.Event _) {
    if (entry.disposed) return;
    if (entry.paused) return;
    if (!_isTopMostScope(entry)) return;
    final tabbables = _tabbablesWithin(container);
    if (tabbables.isNotEmpty) {
      _focusElement(tabbables.last);
    } else if (container is web.HTMLElement) {
      _focusElement(container);
    }
  }

  void onEndSentinelFocus(web.Event _) {
    if (entry.disposed) return;
    if (entry.paused) return;
    if (!_isTopMostScope(entry)) return;
    final tabbables = _tabbablesWithin(container);
    if (tabbables.isNotEmpty) {
      _focusElement(tabbables.first);
    } else if (container is web.HTMLElement) {
      _focusElement(container);
    }
  }

  void onDocumentFocusIn(web.Event e) {
    if (!trapFocus) return;
    if (entry.disposed) return;
    if (entry.paused) return;
    if (!_isTopMostScope(entry)) return;
    if (!container.isConnected) return;

    final target = e.target;
    if (target is! web.Node) return;
    if (container.contains(target)) return;
    if (target is web.Element &&
        target.closest("[data-solid-top-layer]") != null) {
      return;
    }

    // If focus escapes, bring it back to the last focused element inside.
    final preferred = entry.lastFocusedWithin;
    if (preferred != null) {
      _focusElement(preferred);
      return;
    }
    focusInitial();
  }

  final jsContainerFocus = (onContainerFocusIn).toJS;
  final jsStartFocus = (onStartSentinelFocus).toJS;
  final jsEndFocus = (onEndSentinelFocus).toJS;
  final jsDocFocus = (onDocumentFocusIn).toJS;

  container.addEventListener("focusin", jsContainerFocus, true.toJS);
  start.addEventListener("focus", jsStartFocus);
  end.addEventListener("focus", jsEndFocus);

  Timer? docRegister;
  docRegister = Timer(Duration.zero, () {
    web.document.addEventListener("focusin", jsDocFocus, true.toJS);
    docRegister = null;
  });

  void detachSentinel(web.HTMLElement? el) {
    if (el == null) return;
    final parent = el.parentNode;
    if (parent != null) parent.removeChild(el);
  }

  void dispose() {
    if (entry.disposed) return;
    entry.disposed = true;

    docRegister?.cancel();
    docRegister = null;

    container.removeEventListener("focusin", jsContainerFocus, true.toJS);
    start.removeEventListener("focus", jsStartFocus);
    end.removeEventListener("focus", jsEndFocus);
    web.document.removeEventListener("focusin", jsDocFocus, true.toJS);

    detachSentinel(start);
    detachSentinel(end);

    _focusScopeStack.remove(entry);
    _resumeTopScope();

    if (!restoreFocus) return;
    if (onUnmountAutoFocus?.call() == true) return;
    if (_isLikelyFocusableOutside(container)) return;
    _focusElement(entry.previouslyFocused);
  }

  onCleanup(dispose);
  return FocusScopeHandle._(dispose);
}
