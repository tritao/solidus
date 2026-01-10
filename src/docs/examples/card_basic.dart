import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsCardBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final card = Card(
      children: () => [
        CardHeader(
          children: () => [
            web.HTMLHeadingElement.h2()..textContent = "Card title",
            web.HTMLParagraphElement()
              ..className = "muted"
              ..textContent = "A short description.",
          ],
        ),
        CardContent(
          children: () => [
            web.HTMLParagraphElement()
              ..textContent = "Card content goes here.",
          ],
        ),
        CardFooter(
          children: () => [
            web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn secondary"
              ..textContent = "Cancel",
            web.HTMLButtonElement()
              ..type = "button"
              ..className = "btn primary"
              ..textContent = "Continue",
          ],
        ),
      ],
    );
    return card;
  });
  // #doc:endregion snippet
}

