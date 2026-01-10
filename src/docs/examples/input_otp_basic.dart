import "package:solidus/solidus.dart";
import "package:solidus/solidus_ui.dart";
import "package:web/web.dart" as web;

Dispose mountDocsInputOtpBasic(web.Element mount) {
  // #doc:region snippet
  return render(mount, () {
    final code = createSignal("");

    final otp = InputOTP(
      length: 6,
      value: () => code.value,
      setValue: (next) => code.value = next,
      ariaLabel: "Verification code",
    );

    final status = web.HTMLParagraphElement()..className = "muted";
    status.appendChild(text(() => "value=\"${code.value}\""));

    final root = web.HTMLDivElement();
    root.appendChild(otp);
    root.appendChild(status);
    return root;
  });
  // #doc:endregion snippet
}

