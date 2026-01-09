export async function runDocsSliderScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  await page.waitForFunction(
    () => document.querySelector('[data-doc-demo="slider-basic"]') != null,
    { timeout: timeoutMs },
  );

  const scope = page.locator('[data-doc-demo="slider-basic"]');
  const slider = scope.locator('input[type="range"]').first();
  await slider.waitFor({ state: "visible", timeout: timeoutMs });

  await slider.click();
  await page.keyboard.press("ArrowRight");
  await page.waitForTimeout(50);

  const status = await scope.locator(".muted").first().innerText();
  if (!status.includes("value=")) {
    throw new Error(`Expected status to include value=..., got: ${status}`);
  }
}

