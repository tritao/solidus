import "package:solidus/solidus.dart";
import "package:solidus/solidus_dom.dart";
import "package:web/web.dart" as web;

import "package:solidus/solidus_dom/selection/create_selectable_collection.dart";
import "package:solidus/solidus_dom/selection/create_selectable_item.dart";
import "package:solidus/solidus_dom/selection/list_keyboard_delegate.dart";
import "package:solidus/solidus_dom/selection/selection_manager.dart";
import "package:solidus/solidus_dom/selection/types.dart";

Dispose mountDocsSelectionCoreBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final keys = const ["solid", "react", "svelte", "vue", "dart"];
    final disabledKey = "vue";

    final manager = SelectionManager(
      selectionMode: SelectionMode.single,
      selectionBehavior: SelectionBehavior.replace,
      orderedKeys: () => keys,
      isDisabled: (k) => k == disabledKey,
      defaultSelectedKeys: const {"solid"},
    );

    web.HTMLElement? listEl;

    final delegate = ListKeyboardDelegate(
      keys: () => keys,
      isDisabled: (k) => manager.isDisabled(k),
      textValueForKey: (k) => k,
      getContainer: () => listEl,
    );

    final collection = createSelectableCollection(
      selectionManager: () => manager,
      keyboardDelegate: () => delegate,
      ref: () => listEl,
      shouldFocusWrap: () => true,
    );

    final root = web.HTMLDivElement();

    final status = web.HTMLParagraphElement()..className = "muted";
    status.appendChild(
      text(
        () => "Focused: ${manager.focusedKey() ?? "none"} • "
            "Selected: ${manager.firstSelectedKey() ?? "none"}",
      ),
    );
    root.appendChild(status);

    final list = web.HTMLDivElement()
      ..className = "docSelectList";
    listEl = list;
    list.tabIndex = 0;
    list.setAttribute("role", "listbox");
    collection.attach(list);
    root.appendChild(list);

    for (final key in keys) {
      web.HTMLElement? itemEl;
      final item = createSelectableItem(
        selectionManager: () => manager,
        key: () => key,
        ref: () => itemEl,
        disabled: () => key == disabledKey,
        onAction: () {},
      );

      final el = web.HTMLDivElement()
        ..className = "docSelectItem"
        ..setAttribute("role", "option");
      itemEl = el;

      createRenderEffect(() {
        final selected = item.isSelected();
        final disabled = item.isDisabled();
        final focused = manager.focusedKey() == key && manager.isFocused();
        el.setAttribute("aria-selected", selected ? "true" : "false");
        el.setAttribute("aria-disabled", disabled ? "true" : "false");
        el.className = [
          "docSelectItem",
          if (selected) "isSelected",
          if (disabled) "isDisabled",
          if (focused) "isFocused",
        ].join(" ");
        el.textContent = key;
      });

      item.attach(el);
      list.appendChild(el);
    }

    return root;
  });
  // #doc:endregion snippet
}

