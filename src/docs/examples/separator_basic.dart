import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsSeparatorBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final card = div(className: "card", children: [h2("Separator")]);

    card.appendChild(p("Horizontal", className: "muted"));
    card.appendChild(Separator(decorative: true));
    card.appendChild(p("Below the line"));

    card.appendChild(spacer());

    card.appendChild(p("Vertical (inside a row)", className: "muted"));

    final vertRow = row(children: [span("Left")])..style.alignItems = "stretch";
    final v = Separator(orientation: SeparatorOrientation.vertical, decorative: true);
    v.style.height = "24px";
    vertRow.appendChild(v);
    vertRow.appendChild(span("Right"));
    card.appendChild(vertRow);

    return card;
  });
  // #doc:endregion snippet
}
