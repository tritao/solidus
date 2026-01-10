import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsSwitchBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final checked = createSignal(false);

    final sw = Switch(
      checked: () => checked.value,
      setChecked: (next) => checked.value = next,
      ariaLabel: "Enable feature",
    );

    final status =
        p("", className: "muted", children: [text(() => "Checked: ${checked.value}")]);

    return row(children: [sw, status]);
  });
  // #doc:endregion snippet
}
