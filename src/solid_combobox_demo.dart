import "package:dart_web_test/solid.dart";
import "package:dart_web_test/solid_dom.dart";
import "package:web/web.dart" as web;

import "./solid_demo_nav.dart";

void mountSolidComboboxDemo(web.Element mount) {
  render(mount, () {
    final root = web.HTMLDivElement()
      ..id = "combobox-root"
      ..className = "container";

    root.appendChild(solidDemoNav(active: "combobox"));

    final open = createSignal(false);
    final selected = createSignal<String?>(null);
    final lastEvent = createSignal("none");

    root.appendChild(
      web.HTMLHeadingElement.h1()..textContent = "Solid Combobox Demo",
    );

    final status = web.HTMLParagraphElement()
      ..id = "combobox-status"
      ..className = "muted";
    status.appendChild(
      text(() => "Value: ${selected.value ?? "none"} • Last: ${lastEvent.value}"),
    );
    root.appendChild(status);

    final control = web.HTMLDivElement()
      ..id = "combobox-control"
      ..className = "row";
    control.style.gap = "8px";
    control.style.alignItems = "center";

    final input = web.HTMLInputElement()
      ..id = "combobox-input"
      ..className = "input"
      ..placeholder = "Type to filter...";
    control.appendChild(input);

    final after = web.HTMLButtonElement()
      ..id = "combobox-after"
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "After";
    control.appendChild(after);

    root.appendChild(control);

    final opts = <ComboboxOption<String>>[
      const ComboboxOption(value: "One", label: "One"),
      const ComboboxOption(value: "Two", label: "Two"),
      const ComboboxOption(value: "Three", label: "Three"),
      const ComboboxOption(value: "Disabled", label: "Disabled", disabled: true),
      const ComboboxOption(value: "Dart", label: "Dart"),
    ];

    root.appendChild(
      Combobox<String>(
        open: () => open.value,
        setOpen: (next) => open.value = next,
        anchor: control,
        input: input,
        options: () => opts,
        value: () => selected.value,
        setValue: (next) => selected.value = next,
        listboxId: "combobox-listbox",
        portalId: "combobox-portal",
        onClose: (reason) => lastEvent.value = reason,
        placement: "bottom-start",
        offset: 8,
      ),
    );

    return root;
  });
}

