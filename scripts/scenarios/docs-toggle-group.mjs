export async function runDocsToggleGroupScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  const demoSel = '[data-doc-demo="toggle-group-basic"]';

  await page.waitForFunction((sel) => document.querySelector(sel) != null, demoSel, {
    timeout: timeoutMs,
  });

  await page.waitForFunction(
    (sel) => document.querySelectorAll(`${sel} [aria-pressed]`).length >= 6,
    demoSel,
    { timeout: timeoutMs },
  );

  const pressed = async () =>
    await page.evaluate((sel) => {
      const buttons = [...document.querySelectorAll(`${sel} [aria-pressed]`)];
      return buttons.map((el) => ({
        text: el.textContent?.trim() ?? "",
        pressed: el.getAttribute("aria-pressed"),
        disabled: el.getAttribute("aria-disabled"),
      }));
    }, demoSel);

  // Initial: Bold pressed; Underline disabled.
  const initial = await pressed();
  const bold = initial.find((b) => b.text === "Bold");
  const underline = initial.find((b) => b.text.startsWith("Underline"));
  if (bold?.pressed !== "true" || underline?.disabled !== "true") {
    throw new Error(`Unexpected initial state: ${JSON.stringify(initial)}`);
  }

  // Single: click Bold again should deselect (aria-pressed=false).
  await page.locator(`${demoSel} [aria-pressed]`, { hasText: "Bold" }).click();
  await page.waitForTimeout(50);
  const afterDeselect = await pressed();
  const boldAfter = afterDeselect.find((b) => b.text === "Bold");
  if (boldAfter?.pressed !== "false") {
    throw new Error(`Single deselect failed: ${JSON.stringify(afterDeselect)}`);
  }

  // Arrow navigation moves focus: focus Italic, ArrowRight should move to Bold (wrap).
  await page.locator(`${demoSel} [aria-pressed]`, { hasText: "Italic" }).focus();
  await page.keyboard.press("ArrowRight");
  await page.waitForTimeout(50);
  const active = await page.evaluate(() => document.activeElement?.textContent?.trim() ?? "");
  if (active !== "Bold") {
    throw new Error(`ArrowRight did not move focus as expected (active=${active})`);
  }

  // Multiple: click Center and Right results in both pressed.
  await page.locator(`${demoSel} [aria-pressed]`, { hasText: "Center" }).click();
  await page.locator(`${demoSel} [aria-pressed]`, { hasText: "Right" }).click();
  await page.waitForTimeout(50);
  const afterMulti = await pressed();
  const center = afterMulti.find((b) => b.text === "Center");
  const right = afterMulti.find((b) => b.text === "Right");
  if (center?.pressed !== "true" || right?.pressed !== "true") {
    throw new Error(`Multiple toggle failed: ${JSON.stringify(afterMulti)}`);
  }
}

