import "dart:async";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsRuntimeOwnershipBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final running = createSignal(false);
    final ticks = createSignal(0);
    final info = createSignal("stopped");

    Dispose? disposeChild;

    void start() {
      if (running.value) return;
      running.value = true;
      info.value = "running";
      disposeChild = createChildRoot((dispose) {
        final timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          ticks.value++;
        });
        onCleanup(() => timer.cancel());
        return dispose;
      });
    }

    void stop() {
      if (!running.value) return;
      running.value = false;
      info.value = "stopped";
      disposeChild?.call();
      disposeChild = null;
    }

    onCleanup(stop);

    final startBtn = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn primary"
      ..textContent = "Start";
    on(startBtn, "click", (_) => start());

    final stopBtn = web.HTMLButtonElement()
      ..type = "button"
      ..className = "btn secondary"
      ..textContent = "Stop";
    on(stopBtn, "click", (_) => stop());

    final status = p(
      "",
      className: "muted",
      children: [text(() => "${info.value} • ticks=${ticks.value}")],
    );

    return row(children: [startBtn, stopBtn, status]);
  });
  // #doc:endregion snippet
}
