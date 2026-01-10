---
title: Browser router (paths + params)
slug: runtime-browser-router
group: Runtime
order: 70
description: A small path-based router with params, nested routes, Links, and navigation.
status: beta
tags: [runtime, router]
---

For larger apps, Solidus provides a **path-based** browser router built on the Solidus reactive runtime.

If you only need querystring helpers (like `?docs=...`), see: [Routing (URL query)](?docs=runtime-router).

## Pieces

- `BrowserRouter`: tracks location and updates on `popstate` / `hashchange`
- `Routes`: renders the best match (supports nested routes)
- `Link`: client-side navigation without full page reload
- Hooks: `useLocation`, `useNavigate`, `useParams`, `useMatches`
- `Outlet()`: placeholder for nested route children

All are exported from `package:solidus/solidus_router.dart`.

## Router setup

```dart
import "package:solidus/solidus.dart";
import "package:solidus/solidus_dom.dart";
import "package:solidus/solidus_router.dart";
import "package:web/web.dart" as web;

Dispose mountApp(web.Element mount) {
  return render(mount, () {
    final router = BrowserRouter(
      basePath: "", // set to "/my-subpath" if hosting under a subpath
      routes: [
        RouteDef(
          path: "/",
          view: (m) {
            final root = web.HTMLDivElement()..textContent = "Home";
            root.appendChild(Link(to: "/users/123", child: "Go to user 123"));
            return root;
          },
        ),
        RouteDef(
          path: "/users/:id",
          view: (m) => web.HTMLDivElement()..textContent = "User id=${m.params["id"]}",
        ),
      ],
    );

    onCleanup(router.dispose);

    return RouterProvider(
      router: router,
      children: () => Routes(
        fallback: () => (web.HTMLDivElement()..textContent = "Not found"),
      ),
    );
  });
}
```

## Nested routes + `Outlet()`

Nested routes are defined via `children`. Parent routes can render the child route via `Outlet()`.

```dart
final router = BrowserRouter(routes: [
  RouteDef(
    path: "/settings",
    view: (m) {
      final root = web.HTMLDivElement()..textContent = "Settings";
      root.appendChild(insert(root, () => Outlet()));
      return root;
    },
    children: [
      RouteDef(path: "profile", view: (_) => web.HTMLDivElement()..textContent = "Profile"),
      RouteDef(path: "billing", view: (_) => web.HTMLDivElement()..textContent = "Billing"),
      RouteDef(index: true, view: (_) => web.HTMLDivElement()..textContent = "Pick a tab"),
    ],
  ),
]);
```

## Params + navigation

```dart
final params = useParams();
final nav = useNavigate();

final userId = params["id"]; // reactive read

final btn = web.HTMLButtonElement()
  ..type = "button"
  ..textContent = "Go home";
on(btn, "click", (_) => nav("/", replace: true));
```

## Hosting note (history routing)

For path routing on static hosts, you typically need a “SPA fallback” (rewrite all paths to your `index.html`).
Vite dev/preview handles this automatically; GitHub Pages usually needs extra configuration (e.g. a `404.html` redirect).
