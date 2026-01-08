---
title: RadioGroup
slug: radio-group
group: Forms
order: 8
description: Accessible radio group with roving focus and arrow-key selection.
status: beta
tags: [forms, a11y]
---

A radio group represents a **single choice** among multiple options.

## Features

- **ARIA wiring**: container uses `role="radiogroup"`; items use `role="radio"` + `aria-checked`.
- **Keyboard support**: Arrow keys move selection (skipping disabled); Space/Enter selects.
- **Roving focus**: only the active item is tabbable.

## Anatomy

- **Root**: container with `role="radiogroup"`.
- **Item**: interactive element with `role="radio"` (usually a `<button>`).

:::demo id=radio-group-basic title="Basic RadioGroup"
Use Arrow keys to move; Space/Enter selects.
:::

:::code file=src/docs/examples/radio_group_basic.dart region=snippet lang=dart
:::

:::props name=RadioGroup
:::

