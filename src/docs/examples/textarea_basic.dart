import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsTextareaBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final value = createSignal("Hello from Solidus.");

    final el = Textarea(
      placeholder: "Write something…",
      rows: 4,
      value: () => value.value,
      setValue: (next) => value.value = next,
      ariaLabel: "Message",
    );

    final status = p(
      "",
      className: "muted",
      children: [text(() => "${value.value.length} chars")],
    );

    return div(children: [el, status]);
  });
  // #doc:endregion snippet
}
