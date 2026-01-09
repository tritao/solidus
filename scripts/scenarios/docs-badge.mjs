export async function runDocsBadgeScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  const demoSel = '[data-doc-demo="badge-basic"]';

  await page.waitForFunction((sel) => document.querySelector(sel) != null, demoSel, {
    timeout: timeoutMs,
  });

  await page.waitForFunction(
    (sel) => document.querySelectorAll(`${sel} .badge`).length >= 4,
    demoSel,
    { timeout: timeoutMs },
  );

  const classes = await page.evaluate((sel) => {
    const els = [...document.querySelectorAll(`${sel} .badge`)];
    return els.map((el) => el.className);
  }, demoSel);

  const joined = classes.join(" | ");
  if (
    !joined.includes("badge default") ||
    !joined.includes("badge secondary") ||
    !joined.includes("badge outline") ||
    !joined.includes("badge destructive")
  ) {
    throw new Error(`Unexpected badge classes: ${joined}`);
  }
}

