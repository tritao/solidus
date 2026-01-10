import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsFormFieldBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final email = createSignal("");

    String? error() {
      final v = email.value.trim();
      if (v.isEmpty) return "Email is required.";
      if (!v.contains("@")) return "Must include @.";
      return null;
    }

    final control = Input(
      placeholder: "you@example.com",
      value: () => email.value,
      setValue: (next) => email.value = next,
      ariaLabel: "Email",
    );

    return row(children: [
      FormField(
        id: "docs-form-field-basic",
        label: () => "Email",
        description: () => "We only use this for account recovery.",
        error: error,
        control: control,
      ),
    ]);
  });
  // #doc:endregion snippet
}
