import "package:web/web.dart" as web;

const _storageKey = "solidus.theme";
const _accentKey = "solidus.accent";
const _radiusKey = "solidus.radius";

/// Allowed values: `system`, `light`, `dark`.
String getThemePreference() {
  final storage = web.window.localStorage;
  final raw = storage?.getItem(_storageKey);
  switch (raw) {
    case "light":
    case "dark":
    case "system":
      return raw!;
  }
  return "system";
}

void setThemePreference(String mode) {
  final storage = web.window.localStorage;
  if (storage == null) return;
  if (mode == "system") {
    storage.removeItem(_storageKey);
    return;
  }
  storage.setItem(_storageKey, mode);
}

void applyThemePreference(String mode) {
  final root = web.document.documentElement;
  if (root == null) return;

  // `system` means: let CSS `prefers-color-scheme` drive token selection.
  if (mode == "system") {
    root.removeAttribute("data-theme");
    return;
  }

  if (mode == "light" || mode == "dark") {
    root.setAttribute("data-theme", mode);
  }
}

/// Allowed values: `default` (empty), `blue`, `violet`, `emerald`, `rose`, `amber`.
String getAccentPreference() {
  final storage = web.window.localStorage;
  final raw = storage?.getItem(_accentKey);
  switch (raw) {
    case "blue":
    case "violet":
    case "emerald":
    case "rose":
    case "amber":
      return raw!;
  }
  return "default";
}

void setAccentPreference(String accent) {
  final storage = web.window.localStorage;
  if (storage == null) return;
  if (accent == "default") {
    storage.removeItem(_accentKey);
    return;
  }
  storage.setItem(_accentKey, accent);
}

void applyAccentPreference(String accent) {
  final root = web.document.documentElement;
  if (root == null) return;
  if (accent == "default") {
    root.removeAttribute("data-accent");
    return;
  }
  root.setAttribute("data-accent", accent);
}

/// Allowed values: `default` (empty), `none`, `sm`, `md`, `lg`, `xl`.
String getRadiusPreference() {
  final storage = web.window.localStorage;
  final raw = storage?.getItem(_radiusKey);
  switch (raw) {
    case "none":
    case "sm":
    case "md":
    case "lg":
    case "xl":
      return raw!;
  }
  return "default";
}

void setRadiusPreference(String radius) {
  final storage = web.window.localStorage;
  if (storage == null) return;
  if (radius == "default") {
    storage.removeItem(_radiusKey);
    return;
  }
  storage.setItem(_radiusKey, radius);
}

void applyRadiusPreference(String radius) {
  final root = web.document.documentElement;
  if (root == null) return;
  if (radius == "default") {
    root.removeAttribute("data-radius");
    return;
  }
  root.setAttribute("data-radius", radius);
}

/// Reads persisted preference (if any) and applies it to `<html data-theme>`.
void initTheme() {
  applyThemePreference(getThemePreference());
  applyAccentPreference(getAccentPreference());
  applyRadiusPreference(getRadiusPreference());
}
