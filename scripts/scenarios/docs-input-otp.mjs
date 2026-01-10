export async function runDocsInputOtpScenario(page, ctx) {
  const { timeoutMs = 120_000 } = ctx ?? {};

  await page.waitForFunction(
    () => document.querySelector('[data-doc-demo="input-otp-basic"]') != null,
    { timeout: timeoutMs },
  );

  const scope = page.locator('[data-doc-demo="input-otp-basic"]');
  const inputs = scope.locator("input");
  await inputs.first().waitFor({ state: "visible", timeout: timeoutMs });

  await inputs.first().click();
  await page.keyboard.type("123456");
  await page.waitForTimeout(50);

  let status = await scope.locator(".muted").first().innerText();
  if (!status.includes('value="123456"')) {
    throw new Error(`Expected status to include value=\"123456\", got: ${status}`);
  }

  await page.keyboard.press("Backspace");
  await page.waitForTimeout(50);

  status = await scope.locator(".muted").first().innerText();
  if (!status.includes('value="12345"')) {
    throw new Error(`Expected status to include value=\"12345\", got: ${status}`);
  }

  // Regression: last field must not display/accept multiple digits.
  await page.keyboard.type("78");
  await page.waitForTimeout(50);

  status = await scope.locator(".muted").first().innerText();
  if (!status.includes('value="123457"')) {
    throw new Error(`Expected status to include value=\"123457\", got: ${status}`);
  }

  const last = await inputs.nth(5).inputValue();
  if (last !== "7") {
    throw new Error(`Expected last input value to be "7", got: ${last}`);
  }
}
