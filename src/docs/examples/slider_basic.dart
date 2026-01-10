import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsSliderBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final v = createSignal(50.0);

    final slider = Slider(
      value: () => v.value,
      setValue: (next) => v.value = next,
      min: () => 0,
      max: () => 100,
      step: () => 1,
      ariaLabel: "Volume",
    );

    final status = web.HTMLParagraphElement()..className = "muted";
    status.appendChild(text(() => "value=${v.value.toStringAsFixed(0)}"));

    final root = web.HTMLDivElement();
    root.appendChild(slider);
    root.appendChild(status);
    return root;
  });
  // #doc:endregion snippet
}

