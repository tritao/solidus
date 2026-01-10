import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsLabelBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    const id = "docs-label-basic";

    return row(children: [
      FormField(
        id: "docs-label-field",
        label: () => "Name",
        description: () => "A label associated via for/id.",
        control: Input(id: id, placeholder: "Ada Lovelace"),
      ),
    ]);
  });
  // #doc:endregion snippet
}
