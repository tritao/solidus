import "package:web/web.dart" as web;

import "../solid_dom/core/tabs.dart";
import "../solid_dom/selection/types.dart";

/// Styled Tabs (Solidus UI skin).
///
/// For an unstyled primitive, use `createTabs` from `solid_dom`.
web.HTMLElement Tabs({
  required Iterable<TabsItem> items,
  required String? Function() value,
  required void Function(String next) setValue,
  TabsActivationMode Function()? activationMode,
  Orientation Function()? orientation,
  bool Function()? shouldFocusWrap,
  String? ariaLabel,
  String? id,
  String rootClassName = "tabs",
  String tabListClassName = "tabsList",
  String panelsClassName = "tabsPanels",
  String panelClassName = "tabsPanel",
}) {
  return createTabs(
    items: items,
    value: value,
    setValue: setValue,
    activationMode: activationMode,
    orientation: orientation,
    shouldFocusWrap: shouldFocusWrap,
    ariaLabel: ariaLabel,
    id: id,
    rootClassName: rootClassName,
    tabListClassName: tabListClassName,
    panelsClassName: panelsClassName,
    panelClassName: panelClassName,
  );
}

