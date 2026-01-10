# 🛡️ Solidus ✨

UI primitives + a SolidJS-ish reactive runtime for **Dart on the DOM**, with docs + conformance labs, built with **Vite** and `vite-plugin-dart`. 🚀🧩⚡

<p>
  <img alt="Solidus logo" src="public/assets/solidus-logo.png" width="520" />
</p>

## 🌟 What’s in here?

- 📚 **Docs**: component pages + minimal examples → `docs.html?docs=index`
- 🧪 **Labs**: edge cases + Playwright scenarios → `labs.html`
- 🧱 **Runtime**: SolidJS-ish reactivity + component base → `lib/dom_ui/`
- 🧩 **Components**: accessible primitives (overlays, forms, nav, etc.) → `docs.html?docs=index`
- 🧰 **Vite + Dart**: import `.dart` directly via `vite-plugin-dart` → `vendor/vite-plugin-dart/`

![Demo screenshot](public/assets/demo.png)

## 🧠 What this provides (in plain terms) 🧑‍🍳

- ⚡ **Fine-grained reactivity**: signals + computed values + effects (SolidJS style)
- 🧩 **Component model**: a `Component` base class with “hooks”-like helpers (`useSignal`, `useComputed`, `useEffect`, `useReducer`, `useMemo`, `useRef`, `provide`/`useContext`)
- 🧬 **DOM-first rendering**: components build real DOM nodes and patch updates via `morphdom` (no VDOM)
- 🎛️ **A11y-focused primitives**: dialogs, popovers, menus, comboboxes, roving focus, etc. with docs + runnable demos
- 🧪 **Conformance harness**: Playwright scenarios that exercise tricky interaction/overlay edge cases

### ⚡ SolidJS-ish reactivity (Dart)

The runtime includes `Signal`, `Computed`, and `effect`, and components can keep reactive state via `useSignal`/`useComputed`:

```dart
final count = useSignal<int>('count', 0);
final doubleCount = useComputed<int>('double', () => count.value * 2);

useEffect('log', [doubleCount.value], () {
  debugLog('double=${doubleCount.value}');
  return null;
});
```

## 🧩 Component library (what’s included) 🧱

This repo ships a growing set of DOM UI primitives with docs + examples, including:

- 🪟 Overlays: Dialog, Popover, Tooltip, Toast
- 🧭 Menus: DropdownMenu, Menubar, ContextMenu
- 🧾 Forms: Input, InputOTP, FormField, Textarea, Checkbox, RadioGroup, Slider, Select, Combobox, Listbox, ToggleGroup
- 🧠 Focus/interaction: FocusScope, InteractOutside, Roving focus

Browse: `docs.html?docs=index` 📚✨

## ⚡ Quickstart

### ✅ Prereqs

- 🟢 Node.js `^20.19.0 || >=22.12.0`
- 🎯 Dart (optional): if you don’t have `dart`, you can provision it locally (Linux x64 / macOS)

### 🛠️ Install + Run

```bash
npm install
```

If `dart` isn’t installed:

```bash
npm run provision:dart
```

Start dev:

```bash
npm run dev
```

Open (pick your adventure ✨🗺️):

- 📚 Docs: `http://localhost:5173/docs.html?docs=index`
- 🧪 Labs: `http://localhost:5173/labs.html?solid=1`
- 🧪 Solid demos: `http://localhost:5173/labs.html?solid=dialog` (or `overlay`, `popover`, …)
- 🧪 Original “Dart + Vite” demo: `http://localhost:5173/?demos=1`

## 🧪 Headless checks (Playwright) 🤖

- 🧫 Smoke UI (basic app): `npm run debug:ui` (CI: `npm run debug:ui:ci`)
- 📚 Docs suites (CI bundle): `npm run docs:ci`

Artifacts land in `.cache/` 🗂️✨

## 🧱 Build output / Pages-ish behavior 🌍

- 🏗️ `npm run build` defaults to a relative base (`./`) so `dist/index.html` can be served from a subpath.
- 🧩 Override base with `BASE` (or `VITE_BASE`): `BASE=/my-subpath/ npm run build`
- 🚫 Don’t open built output via `file://...` (ESM + CORS); use `npm run preview` instead.

## 🔗 URL flags & state 🧠

In the original demo (`/?demos=1`):

- 🐛 Debug logs: `?debug=1`
- 👥 Users section: `?showUsers=1` / `?showUsers=0`
- 🌐 Users endpoint: `?users=all` / `?users=limited`

## 🗂️ Repo map 🧭

- 🧱 Runtime primitives: `lib/dom_ui/`
- 📦 App shell + demo routes: `src/app/`
- 📚 Docs runtime + demos: `src/docs/` + `docs/pages/` + `tool/build_docs.dart`
- 🧪 Labs / conformance demos: `src/solid/` + `scripts/scenarios/`
- ⚙️ Vite integration: `vite.config.mjs` + `vendor/vite-plugin-dart/`
- 🏛️ Architecture notes: `ARCHITECTURE.md`

## 🧯 Troubleshooting 🧰

- 😵 `dart: not found`: run `npm run provision:dart` (or install Dart, or set `DART=/path/to/dart`)
- 🟠 Node version warnings: upgrade Node to `^20.19.0 || >=22.12.0`

## 🧁 Docs authoring 🍰

Docs pages live in `docs/pages/**/*.md` and compile to `public/assets/docs/` via:

```bash
npm run docs:build
```

For authoring details (frontmatter, directives, props tables): see `docs/README.md`. 📝✨
