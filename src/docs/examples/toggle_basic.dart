import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsToggleBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final onSig = createSignal(false);

    final toggle = Toggle(
      pressed: () => onSig.value,
      setPressed: (next) => onSig.value = next,
      label: "Bold",
      ariaLabel: "Bold toggle",
    );

    final status =
        p("", className: "muted", children: [text(() => "pressed=${onSig.value}")]);

    return row(children: [toggle, status]);
  });
  // #doc:endregion snippet
}
