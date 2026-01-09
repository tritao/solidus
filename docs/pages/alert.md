---
title: Alert
slug: alert
group: UI
order: 6
description: Callout block for status and messaging.
status: beta
tags: [ui, a11y]
---

An alert is a callout block for status, warnings, or important messaging.

## Features

- **Variants**: default/destructive.
- **Composition**: use `AlertTitle(...)` + `AlertDescription(...)`.

:::note
This uses `role="alert"` by default (live-region semantics). If you want a purely visual callout, set `role: ""` or use `role: "status"`.
:::

:::demo id=alert-basic title="Alert"
Default + destructive callouts.
:::

:::code file=src/docs/examples/alert_basic.dart region=snippet lang=dart
:::

:::props name=Alert
:::

