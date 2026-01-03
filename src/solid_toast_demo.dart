import "package:dart_web_test/solid.dart";
import "package:dart_web_test/solid_dom.dart";
import "package:web/web.dart" as web;

import "./solid_demo_nav.dart";

void mountSolidToastDemo(web.Element mount) {
  render(mount, () {
    final root = web.HTMLDivElement()
      ..id = "toast-root"
      ..className = "container";

    root.appendChild(solidDemoNav(active: "toast"));

    final toaster = createToaster(exitMs: 80, defaultDurationMs: 200);
    final count = createSignal(0);

    root.appendChild(web.HTMLHeadingElement.h1()..textContent = "Solid Toast Demo");

    final trigger = web.HTMLButtonElement()
      ..id = "toast-trigger"
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Show toast";
    on(trigger, "click", (_) {
      count.value++;
      toaster.show("Toast ${count.value}");
    });
    root.appendChild(trigger);

    root.appendChild(toaster.view());
    return root;
  });
}
