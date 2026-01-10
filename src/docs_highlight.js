import hljs from "highlight.js/lib/core";

import bash from "highlight.js/lib/languages/bash";
import css from "highlight.js/lib/languages/css";
import dart from "highlight.js/lib/languages/dart";
import javascript from "highlight.js/lib/languages/javascript";
import json from "highlight.js/lib/languages/json";
import xml from "highlight.js/lib/languages/xml";
import yaml from "highlight.js/lib/languages/yaml";

hljs.registerLanguage("bash", bash);
hljs.registerLanguage("css", css);
hljs.registerLanguage("dart", dart);
hljs.registerLanguage("javascript", javascript);
hljs.registerLanguage("json", json);
hljs.registerLanguage("xml", xml);
hljs.registerLanguage("yaml", yaml);

const alias = {
  sh: "bash",
  shell: "bash",
  yml: "yaml",
  js: "javascript",
  html: "xml",
};

hljs.configure({ ignoreUnescapedHTML: true });

export function highlightWithin(root) {
  if (!root) return;

  const codes = root.querySelectorAll("pre code");
  for (const code of codes) {
    if (code.classList.contains("hljs")) continue;

    // Ensure we have a language class whenever possible.
    const pre = code.closest("pre");
    if (
      pre &&
      !Array.from(code.classList).some((c) => c.startsWith("language-"))
    ) {
      const rawLang = pre.getAttribute("data-doc-lang");
      if (rawLang) {
        const lang = alias[rawLang] || rawLang;
        code.classList.add(`language-${lang}`);
      }
    }

    try {
      hljs.highlightElement(code);
    } catch {
      // Ignore unknown languages / highlight errors.
    }
  }
}

