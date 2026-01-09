export async function runDocsThemingScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  await page.waitForFunction(() => document.querySelector("#docs-root") != null, {
    timeout: timeoutMs,
  });

  await page.waitForFunction(
    () => document.querySelector("#docs-accent") && document.querySelector("#docs-radius"),
    { timeout: timeoutMs },
  );

  // Accent: violet.
  await page.selectOption("#docs-accent", "violet");
  await page.waitForTimeout(50);
  const accentAfter = await page.evaluate(() => document.documentElement.getAttribute("data-accent"));
  if (accentAfter !== "violet") {
    throw new Error(`Expected data-accent=violet, got ${accentAfter}`);
  }

  // Radius: lg.
  await page.selectOption("#docs-radius", "lg");
  await page.waitForTimeout(50);
  const radiusAfter = await page.evaluate(() => document.documentElement.getAttribute("data-radius"));
  if (radiusAfter !== "lg") {
    throw new Error(`Expected data-radius=lg, got ${radiusAfter}`);
  }

  // Reset both to default (attribute removed).
  await page.selectOption("#docs-accent", "default");
  await page.selectOption("#docs-radius", "default");
  await page.waitForTimeout(50);
  const afterReset = await page.evaluate(() => ({
    accent: document.documentElement.getAttribute("data-accent"),
    radius: document.documentElement.getAttribute("data-radius"),
  }));
  if (afterReset.accent != null || afterReset.radius != null) {
    throw new Error(`Expected attributes cleared, got ${JSON.stringify(afterReset)}`);
  }
}

