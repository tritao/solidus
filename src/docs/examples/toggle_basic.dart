import "package:dart_web_test/solid.dart";
import "package:dart_web_test/solid_ui.dart";
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

    final status = web.HTMLParagraphElement()..className = "muted";
    status.appendChild(text(() => "pressed=${onSig.value}"));

    final root = web.HTMLDivElement()..className = "row";
    root.appendChild(toggle);
    root.appendChild(status);
    return root;
  });
  // #doc:endregion snippet
}

