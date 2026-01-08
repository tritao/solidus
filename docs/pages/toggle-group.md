---
title: ToggleGroup
slug: toggle-group
group: Forms
order: 9
description: Group of toggle buttons (single or multiple).
status: beta
tags: [forms, a11y]
---

A toggle group is a set of toggle buttons for controlling one (**single**) or many (**multiple**) options.

## Features

- **ARIA wiring**: group uses `role="group"`; items use `aria-pressed`.
- **Keyboard support**: Arrow keys move focus (roving tabindex); Space/Enter toggles.
- **Single + multiple modes**: `type=single` (optionally deselectable), `type=multiple` (set of pressed keys).

## Anatomy

- **Root**: container with `role="group"`.
- **Item**: interactive element (usually a `<button>`) with `aria-pressed`.

:::demo id=toggle-group-basic title="Basic ToggleGroup"
Try Arrow keys to move focus and Space/Enter/click to toggle.
:::

:::code file=src/docs/examples/toggle_group_basic.dart region=snippet lang=dart
:::

:::props name=ToggleGroup
:::

