export async function runDocsSeparatorScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  const demoSel = '[data-doc-demo="separator-basic"]';

  await page.waitForFunction((sel) => document.querySelector(sel) != null, demoSel, {
    timeout: timeoutMs,
  });

  await page.waitForFunction(
    (sel) => document.querySelectorAll(`${sel} .separator`).length >= 2,
    demoSel,
    { timeout: timeoutMs },
  );

  const info = await page.evaluate((sel) => {
    const els = [...document.querySelectorAll(`${sel} .separator`)];
    return els.map((el) => ({
      role: el.getAttribute("role"),
      ariaHidden: el.getAttribute("aria-hidden"),
      ariaOrientation: el.getAttribute("aria-orientation"),
      dataOrientation: el.getAttribute("data-orientation"),
    }));
  }, demoSel);

  // Both are decorative in the demo.
  for (const s of info) {
    if (s.role !== "presentation" || s.ariaHidden !== "true") {
      throw new Error(`Unexpected separator semantics: ${JSON.stringify(info)}`);
    }
    if (s.dataOrientation !== "horizontal" && s.dataOrientation !== "vertical") {
      throw new Error(`Missing data-orientation: ${JSON.stringify(info)}`);
    }
    if (s.ariaOrientation != null) {
      throw new Error(`Decorative separator should not set aria-orientation: ${JSON.stringify(info)}`);
    }
  }
}

