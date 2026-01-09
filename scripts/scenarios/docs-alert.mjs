export async function runDocsAlertScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  const demoSel = '[data-doc-demo="alert-basic"]';

  await page.waitForFunction((sel) => document.querySelector(sel) != null, demoSel, {
    timeout: timeoutMs,
  });

  await page.waitForFunction(
    (sel) => document.querySelectorAll(`${sel} [role="alert"]`).length >= 2,
    demoSel,
    { timeout: timeoutMs },
  );

  const info = await page.evaluate((sel) => {
    const def = document.querySelector(`${sel} [data-test="default"]`);
    const des = document.querySelector(`${sel} [data-test="destructive"]`);
    return {
      defaultRole: def?.getAttribute("role") ?? null,
      destructiveRole: des?.getAttribute("role") ?? null,
      defaultClass: def?.className ?? "",
      destructiveClass: des?.className ?? "",
    };
  }, demoSel);

  if (info.defaultRole !== "alert" || info.destructiveRole !== "alert") {
    throw new Error(`Unexpected alert roles: ${JSON.stringify(info)}`);
  }
  if (!info.defaultClass.includes("alert default") || !info.destructiveClass.includes("alert destructive")) {
    throw new Error(`Unexpected alert classes: ${JSON.stringify(info)}`);
  }
}

