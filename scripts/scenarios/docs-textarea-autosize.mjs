export async function runDocsTextareaAutosizeScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  await page.waitForFunction(
    () =>
      document.querySelector('[data-doc-demo="textarea-autosize-basic"]') !=
      null,
    { timeout: timeoutMs },
  );

  const scope = page.locator('[data-doc-demo="textarea-autosize-basic"]');
  const textarea = scope.locator("textarea").first();
  await textarea.waitFor({ state: "visible", timeout: timeoutMs });

  const h0 = await textarea.evaluate((el) => el.clientHeight);
  await textarea.fill("one\ntwo\nthree\nfour\nfive");
  await page.waitForTimeout(50);
  const h1 = await textarea.evaluate((el) => el.clientHeight);
  if (!(h1 > h0)) {
    throw new Error(`Expected textarea to grow (h0=${h0}, h1=${h1})`);
  }

  const status = await scope.locator(".muted").first().innerText();
  if (!status.includes("chars")) {
    throw new Error(`Expected status to include chars, got: ${status}`);
  }
}

