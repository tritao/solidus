import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsTextareaAutosizeBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final v = createSignal("Type multiple lines…");
    final el = Textarea(
      value: () => v.value,
      setValue: (next) => v.value = next,
      rows: 2,
      autosize: true,
      maxHeightPx: 180,
      ariaLabel: "Autosize textarea",
    );

    final status = p(
      "",
      className: "muted",
      children: [text(() => "${v.value.length} chars")],
    );

    return div(children: [el, status]);
  });
  // #doc:endregion snippet
}
