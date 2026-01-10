import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsRuntimeResourcesBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final version = createSignal(0);

    final res = createResourceWithSource(
      () => version.value,
      (v) async {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        return "result v$v";
      },
    );

    final refetch = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Refetch";
    on(refetch, "click", (_) => version.value++);

    final status = p("", className: "muted", children: [text(() {
      if (res.loading) return "loading…";
      if (res.error != null) return "error: ${res.error}";
      return "value: ${res.value}";
    })]);

    return row(children: [refetch, status]);
  });
  // #doc:endregion snippet
}
