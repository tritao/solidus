import "dart:async";

import "package:solidus/solidus.dart";
import "package:web/web.dart" as web;

import "../selection/create_selectable_collection.dart";
import "../selection/create_selectable_item.dart";
import "../selection/list_keyboard_delegate.dart";
import "../selection/selection_manager.dart";
import "../selection/types.dart";
import "../selection/utils.dart";
import "../solid_dom.dart";

enum ToggleGroupType {
  single,
  multiple,
}

final class ToggleGroupItem {
  ToggleGroupItem({
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

int _toggleGroupIdCounter = 0;
String _nextToggleGroupId(String prefix) {
  _toggleGroupIdCounter++;
  return "$prefix-$_toggleGroupIdCounter";
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

/// ToggleGroup primitive (unstyled; Radix/shadcn-like; Kobalte-style roving focus).
///
/// - Group uses `role="group"`; items use `aria-pressed`.
/// - Arrow keys move focus (roving tabindex), selection changes via click/Space/Enter.
/// - `type=single` allows deselect (value can be null) unless `disallowEmptySelection=true`.
/// - `type=multiple` controls a set of pressed keys.
web.HTMLElement createToggleGroup({
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
  String rootClassName = "",
  String itemClassName = "",
}) {
  final typeAccessor = type;
  final orientationAccessor = orientation ?? () => Orientation.horizontal;
  final shouldFocusWrapAccessor = shouldFocusWrap ?? () => true;
  final disallowEmptySelectionAccessor = disallowEmptySelection ?? () => false;
  final isDisabled = disabled ?? () => false;

  final resolvedId = id ?? _nextToggleGroupId("solid-toggle-group");

  final itemsList = items.toList(growable: false);
  final keys = <String>[];
  final byKey = <String, ToggleGroupItem>{};

  for (var i = 0; i < itemsList.length; i++) {
    final it = itemsList[i];
    var k = it.key;
    if (k.isEmpty) k = it.item.id;
    if (k.isEmpty) k = "$resolvedId-item-$i";
    keys.add(k);
    byKey[k] = it;
  }

  bool itemDisabled(String k) => isDisabled() || (byKey[k]?.disabled ?? false);
  String textValueForKey(String k) => byKey[k]?.textValue ?? "";

  final selection = SelectionManager(
    selectionMode: typeAccessor() == ToggleGroupType.multiple ? SelectionMode.multiple : SelectionMode.single,
    selectionBehavior:
        typeAccessor() == ToggleGroupType.multiple ? SelectionBehavior.toggle : SelectionBehavior.replace,
    disallowEmptySelection: disallowEmptySelectionAccessor(),
    orderedKeys: () => keys,
    isDisabled: itemDisabled,
    canSelectItem: (k) => !itemDisabled(k),
  );

  // If the type changes dynamically, keep SelectionManager consistent.
  createEffect(() {
    final t = typeAccessor();
    selection.setSelectionMode(t == ToggleGroupType.multiple ? SelectionMode.multiple : SelectionMode.single);
    selection.setSelectionBehavior(
      t == ToggleGroupType.multiple ? SelectionBehavior.toggle : SelectionBehavior.replace,
    );
  });

  createEffect(() {
    selection.setDisallowEmptySelection(disallowEmptySelectionAccessor());
  });

  final root = web.HTMLDivElement()
    ..id = resolvedId
    ..className = rootClassName
    ..setAttribute("role", "group");

  if (ariaLabel != null && ariaLabel.isNotEmpty) {
    root.setAttribute("aria-label", ariaLabel);
  }

  createRenderEffect(() {
    final o = orientationAccessor();
    root.setAttribute("aria-orientation", o == Orientation.vertical ? "vertical" : "horizontal");
    final d = isDisabled();
    if (d) {
      root.setAttribute("aria-disabled", "true");
      root.setAttribute("data-disabled", "true");
    } else {
      root.removeAttribute("aria-disabled");
      root.removeAttribute("data-disabled");
    }
  });

  // Sync selection from the controlled value(s).
  createRenderEffect(() {
    if (typeAccessor() == ToggleGroupType.multiple) {
      final get = values;
      if (get == null) {
        throw StateError("ToggleGroup(type: multiple) requires values/setValues");
      }
      final next = get();
      if (!selection.isSelectionEqual(next)) {
        selection.setSelectedKeys(next, force: true);
      }
      if (selection.focusedKey() == null) {
        final first = selection.firstSelectedKey();
        if (first != null) selection.setFocusedKey(first);
      }
      return;
    }

    final get = value;
    if (get == null) {
      throw StateError("ToggleGroup(type: single) requires value/setValue");
    }
    final v = get();
    if (v == null || v.isEmpty) {
      if (!disallowEmptySelectionAccessor()) {
        selection.clearSelection(force: true);
      }
    } else {
      if (byKey[v] == null || itemDisabled(v)) return;
      if (!selection.isSelectionEqual({v})) {
        selection.setSelectedKeys([v], force: true);
      }
      if (selection.focusedKey() != v) {
        selection.setFocusedKey(v);
      }
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

  // When focus leaves the group, reset roving focus to the first selected item
  // (or the first enabled item).
  on(root, "focusout", (e) {
    if (e is! web.FocusEvent) return;
    final related = e.relatedTarget;
    if (related is web.Node && root.contains(related)) return;
    final selected = selection.firstSelectedKey();
    if (selected != null) {
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

  final itemClass = itemClassName.trim();

  for (final k in keys) {
    final it = byKey[k]!;
    final item = it.item;

    if (itemClass.isNotEmpty) item.classList.add(itemClass);

    if (item.id.isEmpty) {
      item.id = "$resolvedId-toggle-$k";
    }

    // If the item is a button, enforce type="button" for safety.
    if (item is web.HTMLButtonElement && item.type.isEmpty) {
      item.type = "button";
    }

    createRenderEffect(() {
      final pressed = selection.isSelected(k);
      item.setAttribute("aria-pressed", pressed ? "true" : "false");
      item.setAttribute("data-state", pressed ? "on" : "off");

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
        if (typeAccessor() == ToggleGroupType.multiple) {
          final set = setValues;
          if (set == null) return;
          set({...selection.selectedKeys()});
          return;
        }
        final set = setValue;
        if (set == null) return;
        set(selection.firstSelectedKey());
      },
    );
    itemSelectable.attach(item);

    // Item-level navigation: Arrow/Home/End move focus only.
    on(item, "keydown", (e) {
      if (e is! web.KeyboardEvent) return;
      if (e.key == " " || e.key == "Enter") return;

      String? next;
      final vertical = orientationAccessor() == Orientation.vertical;
      final wrap = shouldFocusWrapAccessor();

      if ((vertical && e.key == "ArrowDown") || (!vertical && e.key == "ArrowRight")) {
        next = delegate.getKeyBelow(k) ?? (wrap ? delegate.getFirstKey(k) : null);
      } else if ((vertical && e.key == "ArrowUp") || (!vertical && e.key == "ArrowLeft")) {
        next = delegate.getKeyAbove(k) ?? (wrap ? delegate.getLastKey(k) : null);
      } else if (e.key == "Home") {
        next = delegate.getFirstKey(k, true);
      } else if (e.key == "End") {
        next = delegate.getLastKey(k, true);
      } else {
        return;
      }

      if (next == null || next.isEmpty || itemDisabled(next)) return;

      e.preventDefault();
      e.stopPropagation();
      selection.setFocused(true);
      selection.setFocusedKey(next);
      final el = byKey[next]?.item;
      if (el != null) focusWithoutScrolling(el);
    });

    root.appendChild(item);
  }

  return root;
}

