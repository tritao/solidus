export async function runDocsRadioGroupScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  const demoSel = '[data-doc-demo="radio-group-basic"]';

  await page.waitForFunction(
    (sel) => document.querySelector(sel) != null,
    demoSel,
    { timeout: timeoutMs },
  );

  await page.waitForFunction(
    (sel) => document.querySelectorAll(`${sel} [role="radio"]`).length >= 3,
    demoSel,
    { timeout: timeoutMs },
  );

  const readState = async () =>
    await page.evaluate((sel) => {
      const radios = [...document.querySelectorAll(`${sel} [role="radio"]`)];
      return radios.map((el) => ({
        checked: el.getAttribute("aria-checked"),
        disabled: el.getAttribute("aria-disabled"),
      }));
    }, demoSel);

  // Initial: first checked; third disabled.
  const initial = await readState();
  if (
    initial[0]?.checked !== "true" ||
    initial[1]?.checked !== "false" ||
    initial[2]?.disabled !== "true"
  ) {
    throw new Error(`Unexpected initial radio state: ${JSON.stringify(initial)}`);
  }

  // ArrowDown selects next (skipping disabled).
  await page.locator(`${demoSel} [role="radio"]`).first().focus();
  await page.keyboard.press("ArrowDown");
  await page.waitForTimeout(50);
  const afterDown = await readState();
  if (afterDown[1]?.checked !== "true") {
    const active = await page.evaluate(() => {
      const el = document.activeElement;
      if (!el) return null;
      return {
        role: el.getAttribute?.("role") ?? null,
        text: el.textContent ?? null,
        tabIndex: typeof el.tabIndex === "number" ? el.tabIndex : null,
      };
    });
    const tabIndexes = await page.evaluate((sel) => {
      const radios = [...document.querySelectorAll(`${sel} [role="radio"]`)];
      return radios.map((el) => el.tabIndex);
    }, demoSel);
    throw new Error(
      `ArrowDown did not select next: state=${JSON.stringify(afterDown)} active=${JSON.stringify(active)} tabIndexes=${JSON.stringify(tabIndexes)}`,
    );
  }

  // ArrowDown again wraps and skips disabled.
  await page.keyboard.press("ArrowDown");
  await page.waitForTimeout(50);
  const afterWrap = await readState();
  if (afterWrap[0]?.checked !== "true") {
    throw new Error(
      `ArrowDown did not wrap/skip disabled as expected: ${JSON.stringify(afterWrap)}`,
    );
  }

  // Click selects.
  await page.locator(`${demoSel} [role="radio"]`).nth(1).click();
  await page.waitForTimeout(50);
  const afterClick = await readState();
  if (afterClick[1]?.checked !== "true") {
    throw new Error(`Click did not select: ${JSON.stringify(afterClick)}`);
  }
}
