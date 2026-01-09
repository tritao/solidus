export async function runDocsScrollAreaScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  await page.waitForFunction(
    () => document.querySelector('[data-doc-demo="scroll-area-basic"]') != null,
    { timeout: timeoutMs },
  );

  const scope = page.locator('[data-doc-demo="scroll-area-basic"]');
  const viewport = scope.locator(".scrollViewport").first();
  await viewport.waitFor({ state: "visible", timeout: timeoutMs });

  const before = await viewport.evaluate((el) => el.scrollTop);
  await viewport.evaluate((el) => {
    el.scrollTop = 200;
  });
  await page.waitForTimeout(50);
  const after = await viewport.evaluate((el) => el.scrollTop);
  if (!(after > before)) {
    throw new Error(`Expected scrollTop to increase (before=${before}, after=${after})`);
  }
}

