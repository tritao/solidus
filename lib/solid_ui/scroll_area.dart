import "package:web/web.dart" as web;

import "../solid_dom/core/scroll_area.dart";

/// Styled ScrollArea (Solidus UI skin).
ScrollAreaHandle ScrollArea({
  String? id,
  String rootClassName = "scrollArea",
  String viewportClassName = "scrollViewport",
  String contentClassName = "scrollContent",
}) {
  return createScrollArea(
    id: id,
    rootClassName: rootClassName,
    viewportClassName: viewportClassName,
    contentClassName: contentClassName,
  );
}

