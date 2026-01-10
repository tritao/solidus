import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsListboxBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final value = createSignal<String?>(null);

    const opts = [
      SelectOption(value: "solid", label: "Solid"),
      SelectOption(value: "react", label: "React"),
      SelectOption(value: "svelte", label: "Svelte"),
      SelectOption(value: "vue", label: "Vue", disabled: true),
      SelectOption(value: "dart", label: "Dart"),
    ];

    final listbox = createListbox<String, SelectOption<String>>(
      id: "docs-listbox-basic",
      options: () => opts.toList(growable: false),
      selected: () => value.value,
      shouldUseVirtualFocus: true,
      tabFocusable: true,
      onSelect: (opt, _) => value.value = opt.value,
      onClearSelection: () => value.value = null,
    );

    final status = web.HTMLParagraphElement()..className = "muted";
    status.appendChild(text(() => "Value: ${value.value ?? "none"}"));

    final root = web.HTMLDivElement();
    root.appendChild(status);
    root.appendChild(listbox.element);
    return root;
  });
  // #doc:endregion snippet
}
