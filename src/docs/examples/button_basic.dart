import "dart:js_interop";

import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsButtonBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final row1 = row(children: [
      Button(label: "Default"),
      Button(label: "Secondary", variant: ButtonVariant.secondary),
      Button(label: "Outline", variant: ButtonVariant.outline),
      Button(label: "Ghost", variant: ButtonVariant.ghost),
      Button(label: "Destructive", variant: ButtonVariant.destructive),
    ]);

    final row2 = row(children: [
      Button(label: "Small", size: ButtonSize.sm),
      Button(label: "Default", size: ButtonSize.normal),
      Button(label: "Large", size: ButtonSize.lg),
    ]);

    final icon = Button(
      label: "",
      ariaLabel: "Settings",
      size: ButtonSize.icon,
      variant: ButtonVariant.outline,
    );
    icon.innerHTML = (r"""
<svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
  <path fill="currentColor" d="M19.4 13a7.8 7.8 0 0 0 .1-1l2-1.5-2-3.4-2.4 1a7.6 7.6 0 0 0-1.7-1l-.4-2.6H11l-.4 2.6a7.6 7.6 0 0 0-1.7 1l-2.4-1-2 3.4 2 1.5a7.8 7.8 0 0 0 .1 1l-2 1.5 2 3.4 2.4-1c.5.4 1.1.8 1.7 1l.4 2.6h4l.4-2.6c.6-.2 1.2-.6 1.7-1l2.4 1 2-3.4-2-1.5zM13 12a1 1 0 1 1-2 0 1 1 0 0 1 2 0z"/>
</svg>
""").toJS;

    final row3 = row(children: [
      icon,
      Button(label: "Disabled", disabled: true),
      Button(label: "Link", variant: ButtonVariant.link),
    ]);

    return div(children: [
      row1,
      web.HTMLDivElement()..style.height = "10px",
      row2,
      web.HTMLDivElement()..style.height = "10px",
      row3,
    ]);
  });
  // #doc:endregion snippet
}
