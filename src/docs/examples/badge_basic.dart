import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsBadgeBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    return row(children: [
      Badge(label: "Default"),
      Badge(label: "Secondary", variant: BadgeVariant.secondary),
      Badge(label: "Outline", variant: BadgeVariant.outline),
      Badge(label: "Destructive", variant: BadgeVariant.destructive),
    ]);
  });
  // #doc:endregion snippet
}
