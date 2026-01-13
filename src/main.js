import "./style.css";
import { morphPatch } from "../vendor/morph_patch.js";
import "../vendor/floating_ui_bridge.js";
import "./main.dart";

globalThis.morphPatch = morphPatch;

if (import.meta.env?.DEV) {
  globalThis.__solidusBootCount = (globalThis.__solidusBootCount || 0) + 1;
  console.log(`[solidus] boot #${globalThis.__solidusBootCount}`);

  if (import.meta.hot) {
    import.meta.hot.on("vite:beforeFullReload", (payload) => {
      console.warn("[solidus] vite full reload", payload);
    });
  }
}
