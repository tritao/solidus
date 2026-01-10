# 🛡️ Solidus ✨

UI primitives + docs + conformance labs for **Dart on the DOM**, built with **Vite** and `vite-plugin-dart`. 🚀🧩

<p>
  <img alt="Solidus logo" src="public/assets/solidus-logo.png" width="520" />
</p>

## 🌟 What’s in here?

- 📚 **Docs**: component pages + minimal examples → `docs.html?docs=index`
- 🧪 **Labs**: edge cases + Playwright scenarios → `labs.html`
- 🧱 **Runtime**: reusable DOM UI primitives → `lib/dom_ui/`
- 🧰 **Vite + Dart**: import `.dart` directly via `vite-plugin-dart` → `vendor/vite-plugin-dart/`

![Demo screenshot](public/assets/demo.png)

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
