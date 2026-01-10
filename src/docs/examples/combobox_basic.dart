import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsComboboxBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final open = createSignal(false);
    final value = createSignal<String?>(null);

    const opts = [
      ComboboxOption(value: "one", label: "One"),
      ComboboxOption(value: "two", label: "Two"),
      ComboboxOption(value: "three", label: "Three"),
      ComboboxOption(value: "four", label: "Four", disabled: true),
      ComboboxOption(value: "five", label: "Five"),
    ];

    final input = Input(
      id: "docs-combobox-basic-input",
      placeholder: "Type to filter…",
      ariaLabel: "Pick one",
    );

    final control = buildComboboxControl(
      input: input,
      includeTrigger: true,
    );
    final anchor = control.anchor;
    final trigger = control.triggerButton!;

    final status = p(
      "",
      className: "muted",
      children: [text(() => "Value: ${value.value ?? "none"}")],
    );

    return div(children: [
      FormField(
        id: "docs-combobox-basic-field",
        label: () => "Pick one",
        description: () => "Type to filter, then Enter to select.",
        control: anchor,
        a11yTarget: input,
      ),
      status,
      Combobox<String>(
        open: () => open.value,
        setOpen: (next) => open.value = next,
        anchor: anchor,
        input: input,
        triggerButton: trigger,
        portalId: "docs-combobox-basic-portal",
        options: () => opts,
        value: () => value.value,
        setValue: (next) => value.value = next,
        closeOnSelection: true,
      ),
    ]);
  });
  // #doc:endregion snippet
}
