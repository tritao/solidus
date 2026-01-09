import "package:web/web.dart" as web;

import "../solid_dom/core/accordion.dart";
import "../solid_dom/selection/types.dart";

/// Styled Accordion (Solidus UI skin).
///
/// For an unstyled primitive, use `createAccordion` from `solid_dom`.
web.HTMLElement Accordion({
  required Iterable<AccordionItem> items,
  required Set<String> Function() expandedKeys,
  required void Function(Set<String> next) setExpandedKeys,
  bool Function()? multiple,
  bool Function()? collapsible,
  bool Function()? shouldFocusWrap,
  Orientation Function()? orientation,
  String? ariaLabel,
  String? id,
  String rootClassName = "accordion",
  String itemClassName = "accordionItem",
  String triggerClassName = "accordionTrigger",
  String panelClassName = "accordionPanel",
}) {
  return createAccordion(
    items: items,
    expandedKeys: expandedKeys,
    setExpandedKeys: setExpandedKeys,
    multiple: multiple,
    collapsible: collapsible,
    shouldFocusWrap: shouldFocusWrap,
    orientation: orientation,
    ariaLabel: ariaLabel,
    id: id,
    rootClassName: rootClassName,
    itemClassName: itemClassName,
    triggerClassName: triggerClassName,
    panelClassName: panelClassName,
  );
}

