import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "./listbox_core.dart";
import "./solid_dom.dart";

typedef ListboxOptionBuilder<T, O extends ListboxItem<T>> = web.HTMLElement
    Function(
  O option, {
  required bool selected,
  required bool active,
});

final class ListboxHandle<T, O extends ListboxItem<T>> {
  ListboxHandle._(
    this.element, {
    required this.activeIndex,
    required this.activeId,
    required this.setActiveIndex,
    required this.selectActive,
    required this.moveActive,
    required this.focusActive,
  });

  final web.HTMLElement element;
  final Signal<int> activeIndex;
  final String? Function() activeId;

  /// Sets active index and updates option tabIndex/scrolling; focuses option if
  /// not in virtual focus mode.
  final void Function(int next) setActiveIndex;

  /// Selects the active option (if any).
  final void Function() selectActive;

  /// Move active by delta (uses enabled navigation + wrapping rules).
  final void Function(int delta) moveActive;

  /// Focuses the active option if not in virtual focus mode.
  final void Function() focusActive;
}

ListboxHandle<T, O> createListbox<T, O extends ListboxItem<T>>({
  required String id,
  required List<O> Function() options,
  required T? Function() selected,
  required void Function(O option, int index) onSelect,
  bool Function(T a, T b)? equals,
  Signal<int>? activeIndex,
  int Function()? initialActiveIndex,
  bool shouldUseVirtualFocus = false,
  bool shouldFocusOnHover = true,
  bool shouldFocusWrap = true,
  bool disallowTypeAhead = false,
  bool enableKeyboardNavigation = true,
  void Function()? onTabOut,
  void Function()? onEscape,
  String emptyText = "No results.",
  bool showEmptyState = false,
  ListboxOptionBuilder<T, O>? optionBuilder,
}) {
  final eq = equals ?? defaultListboxEquals<T>;
  final listbox = web.HTMLDivElement()
    ..id = id
    ..setAttribute("role", "listbox")
    ..tabIndex = shouldUseVirtualFocus ? -1 : -1
    ..className = "card";

  final activeIndexSig = activeIndex ??
      createSignal<int>(
        initialActiveIndex?.call() ??
            (() {
              final opts = options();
              final sel = selected();
              final idx = findSelectedIndex<T, O>(opts, sel, equals: eq);
              return idx == -1 ? firstEnabledIndex(opts) : idx;
            })(),
      );

  final optionEls = <web.HTMLElement>[];

  String? activeId() {
    final idx = activeIndexSig.value;
    final opts = options();
    if (idx < 0 || idx >= opts.length) return null;
    return optionIdFor(opts, id, idx);
  }

  void scrollActiveIntoView() {
    final idx = activeIndexSig.value;
    if (idx < 0 || idx >= optionEls.length) return;
    final el = optionEls[idx];
    try {
      el.scrollIntoView();
    } catch (_) {}
  }

  void focusActive() {
    if (shouldUseVirtualFocus) return;
    final idx = activeIndexSig.value;
    if (idx < 0 || idx >= optionEls.length) return;
    try {
      optionEls[idx].focus();
    } catch (_) {}
  }

  void syncTabIndex() {
    if (optionEls.isEmpty) return;
    final active = activeIndexSig.value.clamp(0, optionEls.length - 1);
    for (var i = 0; i < optionEls.length; i++) {
      optionEls[i].tabIndex = shouldUseVirtualFocus ? -1 : (i == active ? 0 : -1);
      if (i == active) {
        optionEls[i].setAttribute("data-active", "true");
      } else {
        optionEls[i].removeAttribute("data-active");
      }
    }
  }

  void setActiveIndex(int next) {
    final opts = options();
    if (opts.isEmpty) {
      activeIndexSig.value = -1;
      return;
    }
    var idx = next;
    if (idx < 0) idx = 0;
    if (idx >= opts.length) idx = opts.length - 1;
    if (opts[idx].disabled) {
      idx = nextEnabledIndex(opts, idx, 1);
    }
    activeIndexSig.value = idx;
    scheduleMicrotask(() {
      syncTabIndex();
      scrollActiveIntoView();
      focusActive();
    });
  }

  void moveActive(int delta) {
    final opts = options();
    if (opts.isEmpty) return;
    final current = activeIndexSig.value;
    int next;
    if (!shouldFocusWrap) {
      next = (current + delta).clamp(0, opts.length - 1);
      if (opts[next].disabled) {
        next = delta > 0 ? nextEnabledIndex(opts, next, 1) : nextEnabledIndex(opts, next, -1);
      }
    } else {
      next = nextEnabledIndex(opts, current < 0 ? 0 : current, delta);
    }
    setActiveIndex(next);
  }

  void selectActive() {
    final idx = activeIndexSig.value;
    final opts = options();
    if (idx < 0 || idx >= opts.length) return;
    final opt = opts[idx];
    if (opt.disabled) return;
    onSelect(opt, idx);
  }

  final typeahead = ListboxTypeahead();

  void onKeydown(web.Event e) {
    if (!enableKeyboardNavigation) return;
    if (e is! web.KeyboardEvent) return;
    final opts = options();
    if (e.key == "Tab") {
      onTabOut?.call();
      return;
    }
    if (e.key == "Escape") {
      e.preventDefault();
      onEscape?.call();
      return;
    }
    if (opts.isEmpty) return;

    int? next;
    switch (e.key) {
      case "ArrowDown":
        next = shouldFocusWrap
            ? nextEnabledIndex(opts, activeIndexSig.value, 1)
            : (activeIndexSig.value + 1).clamp(0, opts.length - 1);
        break;
      case "ArrowUp":
        next = shouldFocusWrap
            ? nextEnabledIndex(opts, activeIndexSig.value, -1)
            : (activeIndexSig.value - 1).clamp(0, opts.length - 1);
        break;
      case "Home":
        next = firstEnabledIndex(opts);
        break;
      case "End":
        next = lastEnabledIndex(opts);
        break;
      case "Enter":
      case " ":
        e.preventDefault();
        selectActive();
        return;
    }

    if (next != null) {
      e.preventDefault();
      setActiveIndex(next);
      return;
    }

    if (!disallowTypeAhead) {
      final match = typeahead.handleKey(e, opts, startIndex: activeIndexSig.value);
      if (match != null) {
        e.preventDefault();
        setActiveIndex(match);
      }
    }
  }

  on(listbox, "keydown", onKeydown);
  onCleanup(typeahead.dispose);

  web.HTMLElement buildOption(O option, int idx, bool selected, bool active) {
    final el = optionBuilder != null
        ? optionBuilder(option, selected: selected, active: active)
        : (web.HTMLDivElement()
          ..className = "menuItem"
          ..textContent = option.label);

    el.setAttribute("role", "option");
    el.id = optionIdFor(options(), id, idx);
    el.setAttribute("aria-selected", selected ? "true" : "false");
    if (option.disabled) el.setAttribute("aria-disabled", "true");
    if (active) el.setAttribute("data-active", "true");
    el.tabIndex = shouldUseVirtualFocus ? -1 : (active ? 0 : -1);

    if (shouldUseVirtualFocus) {
      on(el, "pointerdown", (ev) {
        // Keep focus on the virtual focus target (e.g., input).
        ev.preventDefault();
      });
    }

    on(el, "pointermove", (_) {
      if (!shouldFocusOnHover) return;
      if (option.disabled) return;
      activeIndexSig.value = idx;
      scheduleMicrotask(() {
        syncTabIndex();
        scrollActiveIntoView();
        focusActive();
      });
    });

    on(el, "click", (_) {
      if (option.disabled) return;
      activeIndexSig.value = idx;
      selectActive();
    });

    return el;
  }

  createRenderEffect(() {
    listbox.textContent = "";
    optionEls.clear();
    final opts = options();
    final sel = selected();

    if (opts.isEmpty) {
      activeIndexSig.value = -1;
      if (showEmptyState) {
        final empty = web.HTMLDivElement()
          ..setAttribute("data-empty", "1")
          ..textContent = emptyText;
        empty.style.padding = "10px 12px";
        empty.style.opacity = "0.8";
        listbox.appendChild(empty);
      }
      return;
    }

    // Clamp active index to range and make sure it's enabled.
    var active = activeIndexSig.value;
    if (active < 0) active = firstEnabledIndex(opts);
    if (active >= opts.length) active = opts.length - 1;
    if (active >= 0 && opts[active].disabled) active = nextEnabledIndex(opts, active, 1);
    activeIndexSig.value = active;

    for (var i = 0; i < opts.length; i++) {
      final opt = opts[i];
      final isSelected = sel != null && eq(opt.value, sel);
      final isActive = i == activeIndexSig.value;
      final el = buildOption(opt, i, isSelected, isActive);
      optionEls.add(el);
      listbox.appendChild(el);
    }

    scheduleMicrotask(() {
      syncTabIndex();
      scrollActiveIntoView();
    });
  });

  return ListboxHandle._(
    listbox,
    activeIndex: activeIndexSig,
    activeId: activeId,
    setActiveIndex: setActiveIndex,
    selectActive: selectActive,
    moveActive: moveActive,
    focusActive: focusActive,
  );
}
