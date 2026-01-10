import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsTableBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    return Table(
      head: () => [
        TableRow(
          children: () => [
            TableHeadCell(text: "Name"),
            TableHeadCell(text: "Role"),
            TableHeadCell(text: "Status"),
          ],
        ),
      ],
      body: () => [
        TableRow(
          children: () => [
            TableCell(text: "Ada Lovelace"),
            TableCell(text: "Engineer"),
            TableCell(text: "Active"),
          ],
        ),
        TableRow(
          children: () => [
            TableCell(text: "Grace Hopper"),
            TableCell(text: "Admiral"),
            TableCell(text: "Active"),
          ],
        ),
      ],
    );
  });
  // #doc:endregion snippet
}

