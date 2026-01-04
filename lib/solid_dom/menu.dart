import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

import "./floating.dart";
import "./focus_scope.dart";
import "./overlay.dart";
import "./presence.dart";
import "./selection/create_selectable_collection.dart";
import "./selection/create_selectable_item.dart";
import "./selection/list_keyboard_delegate.dart";
import "./selection/selection_manager.dart";
import "./selection/types.dart";
import "./selection/utils.dart";
import "./solid_dom.dart";

final class MenuContent {
  MenuContent({
    required this.element,
    required this.items,
    this.initialActiveIndex = 0,
  });

  final web.HTMLElement element;
  final List<web.HTMLElement> items;
  final int initialActiveIndex;
}

typedef DropdownMenuBuilder = MenuContent Function(
    void Function([String reason]) close);

web.DocumentFragment DropdownMenu({
  required bool Function() open,
  required void Function(bool next) setOpen,
  required web.Element anchor,
  required DropdownMenuBuilder builder,
  void Function(String reason)? onClose,
  void Function(FocusScopeAutoFocusEvent event)? onOpenAutoFocus,
  void Function(FocusScopeAutoFocusEvent event)? onCloseAutoFocus,
  int exitMs = 120,
  String placement = "bottom-start",
  double offset = 4,
  double viewportPadding = 8,
  bool flip = true,
  String? portalId,
}) {
  return Presence(
    when: open,
    exitMs: exitMs,
    children: () => Portal(
      id: portalId,
      children: () {
        var closeReason = "close";

        void close([String reason = "close"]) {
          closeReason = reason;
          onClose?.call(reason);
          setOpen(false);
        }

        final built = builder(close);
        final menu = built.element;
        final items = built.items;

        menu
          ..setAttribute("role", "menu")
          ..tabIndex = -1;

        bool isItemDisabled(web.HTMLElement el) {
          if (el is web.HTMLButtonElement) return el.disabled;
          return el.getAttribute("aria-disabled") == "true";
        }

        final keys = <String>[];
        final elByKey = <String, web.HTMLElement>{};
        for (var i = 0; i < items.length; i++) {
          final el = items[i];
          var key = el.id;
          if (key.isEmpty) {
            key = "solid-menu-item-$i";
            el.id = key;
          }
          keys.add(key);
          elByKey[key] = el;
        }

        final selection = SelectionManager(
          selectionMode: SelectionMode.none,
          selectionBehavior: SelectionBehavior.replace,
          orderedKeys: () => keys,
          isDisabled: (k) => isItemDisabled(elByKey[k] ?? menu),
          canSelectItem: (k) => !isItemDisabled(elByKey[k] ?? menu),
        );

        final initialIndex = built.initialActiveIndex
            .clamp(0, keys.isEmpty ? 0 : keys.length - 1);
        if (keys.isNotEmpty) {
          for (var i = 0; i < keys.length; i++) {
            final idx = (initialIndex + i) % keys.length;
            final k = keys[idx];
            if (!isItemDisabled(elByKey[k] ?? menu)) {
              selection.setFocusedKey(k);
              break;
            }
          }
        }

        final delegate = ListKeyboardDelegate(
          keys: () => keys,
          isDisabled: (k) => isItemDisabled(elByKey[k] ?? menu),
          textValueForKey: (k) => (elByKey[k]?.textContent ?? ""),
          getContainer: () => menu,
          getItemElement: (k) => elByKey[k],
        );

        final selectable = createSelectableCollection(
          selectionManager: () => selection,
          keyboardDelegate: () => delegate,
          ref: () => menu,
          scrollRef: () => menu,
          shouldFocusWrap: () => true,
          disallowTypeAhead: () => false,
          shouldUseVirtualFocus: () => false,
          allowsTabNavigation: () => true,
          orientation: () => Orientation.vertical,
        );

        floatToAnchor(
          anchor: anchor,
          floating: menu,
          placement: placement,
          offset: offset,
          viewportPadding: viewportPadding,
          flip: flip,
          updateOnScrollParents: true,
        );

        // Prevent the common "click trigger to close then click toggles open"
        // issue by excluding the anchor from outside dismissal.
        dismissableLayer(
          menu,
          excludedElements: <web.Element? Function()>[
            () => anchor,
          ],
          onDismiss: (reason) => close(reason),
        );

        for (final entry in elByKey.entries) {
          final key = entry.key;
          final el = entry.value;
          el.setAttribute("data-key", key);

          final itemSelectable = createSelectableItem(
            selectionManager: () => selection,
            key: () => key,
            ref: () => el,
            disabled: () => isItemDisabled(el),
          );
          itemSelectable.attach(el);

          createRenderEffect(() {
            if (selection.focusedKey() == key) {
              el.setAttribute("data-active", "true");
            } else {
              el.removeAttribute("data-active");
            }
          });

          on(el, "pointermove", (ev) {
            if (ev is! web.PointerEvent) return;
            if (ev.pointerType != "mouse") return;
            if (isItemDisabled(el)) return;
            if (selection.focusedKey() == key && web.document.activeElement == el) return;
            selection.setFocusedKey(key);
            focusWithoutScrolling(el);
          });
        }

        void onKeyDown(web.Event e) {
          if (e is! web.KeyboardEvent) return;
          if (e.key == "Tab") {
            close("tab");
            return;
          }

          // Mirror Kobalte: Alt+ArrowUp closes.
          if (e.key == "ArrowUp" && e.altKey) {
            e.preventDefault();
            close("escape");
            return;
          }

          selectable.onKeyDown(e);
        }

        on(menu, "keydown", onKeyDown);
        on(menu, "mousedown", (e) {
          if (e is web.MouseEvent) selectable.onMouseDown(e);
        });
        on(menu, "focusin", (e) {
          if (e is web.FocusEvent) selectable.onFocusIn(e);
        });
        on(menu, "focusout", (e) {
          if (e is web.FocusEvent) selectable.onFocusOut(e);
        });

        // Focus a reasonable item on mount.
        focusScope(
          menu,
          trapFocus: false,
          restoreFocus: true,
          onMountAutoFocus: (e) {
            onOpenAutoFocus?.call(e);
            if (e.defaultPrevented) return;
            e.preventDefault();
            scheduleMicrotask(() => focusWithoutScrolling(menu));
          },
          onUnmountAutoFocus: (e) {
            onCloseAutoFocus?.call(e);
            if (e.defaultPrevented) return;
            if (closeReason == "tab") e.preventDefault();
          },
        );

        return menu;
      },
    ),
  );
}
