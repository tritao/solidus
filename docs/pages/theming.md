---
title: Theming
slug: theming
group: UI
order: 0
description: Theme tokens, accent palettes, and radius presets.
status: beta
tags: [ui, tokens, theming]
---

Solidus theming is driven by **CSS variables** in `src/styles/tokens.css`.

## Theme mode

- `data-theme="light" | "dark"` forces a mode.
- No `data-theme` means **system** (`prefers-color-scheme`).

## Accent palettes

Set `data-accent="blue|violet|emerald|rose|amber"` to override:

- `--primary`
- `--primary-foreground`
- `--ring`

This changes the default button color, focus rings, and other “primary” surfaces.

## Radius presets

Set `data-radius="none|sm|md|lg|xl"` to override `--radius`.

## Where it’s applied

Preferences are persisted in `localStorage` and applied early (before Vite loads JS) to avoid theme “flash”.

