import "package:web/web.dart" as web;

import "package:dart_web_test/wordproc/wordproc.dart";

void main() {
  final mount = web.document.querySelector("#app");
  if (mount == null) return;
  mountSolidWordprocShellDemo(mount);
}

