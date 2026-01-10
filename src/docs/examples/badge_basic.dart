import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsBadgeBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final row = web.HTMLDivElement()..className = "row";
    row.appendChild(Badge(label: "Default"));
    row.appendChild(Badge(label: "Secondary", variant: BadgeVariant.secondary));
    row.appendChild(Badge(label: "Outline", variant: BadgeVariant.outline));
    row.appendChild(Badge(label: "Destructive", variant: BadgeVariant.destructive));
    return row;
  });
  // #doc:endregion snippet
}
