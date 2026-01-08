import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "./selection/create_selectable_collection.dart";
import "./selection/create_selectable_item.dart";
import "./selection/list_keyboard_delegate.dart";
import "./selection/selection_manager.dart";
import "./selection/types.dart";
import "./selection/utils.dart";
import "./solid_dom.dart";

final class RadioGroupItem {
  RadioGroupItem({
    required this.key,
    required this.item,
    this.disabled = false,
    String? textValue,
  }) : textValue = textValue ?? (item.textContent ?? "");

  final String key;
  final web.HTMLElement item;
  final bool disabled;
  final String textValue;
}

int _radioGroupIdCounter = 0;
String _nextRadioGroupId(String prefix) {
  _radioGroupIdCounter++;
  return "$prefix-$_radioGroupIdCounter";
}

bool _isRtl() {
  try {
    final html = web.document.documentElement;
    final dir = html?.getAttribute("dir") ?? web.document.dir;
    return (dir ?? "").toLowerCase() == "rtl";
  } catch (_) {
    return false;
  }
}

/// RadioGroup primitive (Kobalte-style semantics + roving focus).
///
/// - Container uses `role="radiogroup"`.
/// - Items use `role="radio"` + `aria-checked`.
/// - Arrow keys move selection/focus (skipping disabled).
/// - Space/Enter selects focused item.
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
  final orientationAccessor = orientation ?? () => Orientation.vertical;
  final shouldFocusWrapAccessor = shouldFocusWrap ?? () => true;
  final isDisabled = disabled ?? () => false;

  final resolvedId = id ?? _nextRadioGroupId("solid-radio-group");

  final itemsList = items.toList(growable: false);
  final keys = <String>[];
  final byKey = <String, RadioGroupItem>{};

  for (var i = 0; i < itemsList.length; i++) {
    final it = itemsList[i];
    var k = it.key;
    if (k.isEmpty) k = it.item.id;
    if (k.isEmpty) k = "$resolvedId-item-$i";
    keys.add(k);
    byKey[k] = it;
  }

  bool itemDisabled(String k) =>
      isDisabled() || (byKey[k]?.disabled ?? false);
  String textValueForKey(String k) => byKey[k]?.textValue ?? "";

  final selection = SelectionManager(
    selectionMode: SelectionMode.single,
    selectionBehavior: SelectionBehavior.replace,
    orderedKeys: () => keys,
    isDisabled: itemDisabled,
    canSelectItem: (k) => !itemDisabled(k),
  );

  final root = web.HTMLDivElement()
    ..id = resolvedId
    ..className = rootClassName
    ..setAttribute("role", "radiogroup");

  if (ariaLabel != null && ariaLabel.isNotEmpty) {
    root.setAttribute("aria-label", ariaLabel);
  }

  createRenderEffect(() {
    final o = orientationAccessor();
    root.setAttribute(
      "aria-orientation",
      o == Orientation.vertical ? "vertical" : "horizontal",
    );
  });

  // Sync selection to the controlled value.
  createRenderEffect(() {
    final v = value();
    if (v == null || v.isEmpty) return;
    if (byKey[v] == null || itemDisabled(v)) return;

    if (!selection.isSelectionEqual({v})) {
      selection.setSelectedKeys([v], force: true);
    }
    if (selection.focusedKey() != v) {
      selection.setFocusedKey(v);
    }
  });

  // Ensure we always have a focusedKey for roving tabIndex.
  createRenderEffect(() {
    final focused = selection.focusedKey();
    if (focused != null && byKey[focused] != null && !itemDisabled(focused)) {
      return;
    }
    final selected = selection.firstSelectedKey();
    if (selected != null && !itemDisabled(selected)) {
      selection.setFocusedKey(selected);
      return;
    }
    for (final k in keys) {
      if (!itemDisabled(k)) {
        selection.setFocusedKey(k);
        return;
      }
    }
  });

  // When selection changes due to user interaction, update the controlled value.
  createEffect(() {
    final selected = selection.firstSelectedKey();
    if (selected == null || selected.isEmpty) return;
    if (value() == selected) return;
    if (itemDisabled(selected)) return;
    setValue(selected);
  });

  // When focus leaves the group, reset roving focus to the selected item (so
  // Tab back into the group focuses the checked radio).
  on(root, "focusout", (e) {
    if (e is! web.FocusEvent) return;
    final related = e.relatedTarget;
    if (related is web.Node && root.contains(related)) return;
    final selected = selection.firstSelectedKey();
    if (selected != null) selection.setFocusedKey(selected);
  });

  final delegate = ListKeyboardDelegate(
    keys: () => keys,
    isDisabled: itemDisabled,
    textValueForKey: textValueForKey,
    getContainer: () => root,
    getItemElement: (k) => byKey[k]?.item,
  );

  final selectable = createSelectableCollection(
    selectionManager: () => selection,
    keyboardDelegate: () => delegate,
    ref: () => root,
    scrollRef: () => root,
    shouldFocusWrap: shouldFocusWrapAccessor,
    selectOnFocus: () => false,
    disallowTypeAhead: () => true,
    shouldUseVirtualFocus: () => false,
    allowsTabNavigation: () => true,
    orientation: orientationAccessor,
    isRtl: _isRtl,
  );
  selectable.attach(root);

  for (final k in keys) {
    final it = byKey[k]!;
    final item = it.item;

    item.classList.add(itemClassName);
    item.setAttribute("role", "radio");

    if (item.id.isEmpty) {
      item.id = "$resolvedId-radio-$k";
    }

    createRenderEffect(() {
      final checked = value() == k;
      item.setAttribute("aria-checked", checked ? "true" : "false");
      item.setAttribute("data-state", checked ? "checked" : "unchecked");

      final d = itemDisabled(k);
      if (d) {
        item.setAttribute("aria-disabled", "true");
        item.setAttribute("data-disabled", "true");
        if (item is web.HTMLButtonElement) item.disabled = true;
      } else {
        item.removeAttribute("aria-disabled");
        item.removeAttribute("data-disabled");
        if (item is web.HTMLButtonElement) item.disabled = false;
      }
    });

    final itemSelectable = createSelectableItem(
      selectionManager: () => selection,
      key: () => k,
      ref: () => item,
      disabled: () => itemDisabled(k),
      shouldSelectOnPressUp: () => true,
      allowsDifferentPressOrigin: () => false,
      onAction: () {
        if (itemDisabled(k)) return;
        setValue(k);
      },
    );
    itemSelectable.attach(item);

    // Handle Arrow/Home/End at the item level:
    // - in radio groups, arrow navigation should also change selection.
    // - some environments don't reliably bubble key events from <button> to the
    //   radiogroup container; handling here is more robust.
    on(item, "keydown", (e) {
      if (e is! web.KeyboardEvent) return;
      if (e.key == " ") {
        e.preventDefault();
        return;
      }
      if (e.key == "Enter") return;

      String? next;
      final vertical = orientationAccessor() == Orientation.vertical;
      if ((vertical && e.key == "ArrowDown") || (!vertical && e.key == "ArrowRight")) {
        next = delegate.getKeyBelow(k) ?? (shouldFocusWrapAccessor() ? delegate.getFirstKey(k) : null);
      } else if ((vertical && e.key == "ArrowUp") || (!vertical && e.key == "ArrowLeft")) {
        next = delegate.getKeyAbove(k) ?? (shouldFocusWrapAccessor() ? delegate.getLastKey(k) : null);
      } else if (e.key == "Home") {
        next = delegate.getFirstKey(k, true);
      } else if (e.key == "End") {
        next = delegate.getLastKey(k, true);
      } else if (e.key == "PageDown") {
        next = delegate.getKeyPageBelow(k);
      } else if (e.key == "PageUp") {
        next = delegate.getKeyPageAbove(k);
      } else {
        return;
      }

      if (next == null || next.isEmpty || itemDisabled(next)) return;

      e.preventDefault();
      // Prevent double-handling if the event also bubbles to the root (and to
      // keep the behavior consistent between environments).
      e.stopPropagation();

      selection.setFocusedKey(next);
      setValue(next);

      final nextEl = byKey[next]?.item;
      if (nextEl != null) {
        focusWithoutScrolling(nextEl);
      }
    });

    root.appendChild(item);
  }

  // Run after first paint to ensure roving focus has a valid fallback even if
  // the controlled value is missing.
  scheduleMicrotask(() {
    final v = value();
    if (v != null && v.isNotEmpty && byKey[v] != null && !itemDisabled(v)) {
      return;
    }
    for (final k in keys) {
      if (!itemDisabled(k)) {
        selection.setFocusedKey(k);
        return;
      }
    }
  });

  return root;
}
