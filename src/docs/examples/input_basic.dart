import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsInputBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final value = createSignal("");
    final disabled = createSignal(false);

    final input = Input(
      id: "docs-input-basic",
      placeholder: "Type here…",
      value: () => value.value,
      setValue: (next) => value.value = next,
      disabled: () => disabled.value,
      ariaLabel: "Example input",
    );

    final toggle = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary";
    toggle.appendChild(text(
      () => disabled.value ? "Enable input" : "Disable input",
    ));
    on(toggle, "click", (_) => disabled.value = !disabled.value);

    final status = p(
      "",
      className: "muted",
      children: [text(() => "value=\"${value.value}\"")],
    );

    return row(children: [input, toggle, status]);
  });
  // #doc:endregion snippet
}
