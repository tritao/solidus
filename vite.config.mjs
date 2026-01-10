import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { defineConfig, loadEnv } from "vite";
import Dart from "vite-plugin-dart";

export default defineConfig(({ mode, command }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const provisionedDart = path.join(
    process.cwd(),
    ".dart-sdk",
    "dart-sdk",
    "bin",
    "dart",
  );
  const dart =
    env.DART ??
    process.env.DART ??
    (fs.existsSync(provisionedDart) ? provisionedDart : "dart");

  // GitHub Pages serves the app at /<repo>/, so the build must use that base.
  const githubRepo = process.env.GITHUB_REPOSITORY?.split("/")[1];
  const explicitBase =
    env.BASE ??
    env.VITE_BASE ??
    process.env.BASE ??
    process.env.VITE_BASE ??
    null;
  const base = explicitBase
    ? explicitBase
    : process.env.GITHUB_ACTIONS && githubRepo
      ? `/${githubRepo}/`
      : command === "build"
        ? "./"
        : "/";

  const buildWordproc =
    env.BUILD_WORDPROC === "1" ||
    env.VITE_BUILD_WORDPROC === "1" ||
    process.env.BUILD_WORDPROC === "1" ||
    process.env.VITE_BUILD_WORDPROC === "1";

  const ensureDartPubGet = () => {
    const packageConfig = path.join(
      process.cwd(),
      ".dart_tool",
      "package_config.json",
    );
    if (fs.existsSync(packageConfig)) return;
    console.log(
      `[solidus] Missing .dart_tool/package_config.json; running "${dart} pub get"`,
    );
    const result = spawnSync(dart, ["pub", "get"], { stdio: "inherit" });
    const status = result.status ?? 1;
    if (status !== 0) {
      throw new Error(`[solidus] dart pub get failed (exit ${status})`);
    }
  };

  return {
    base,
    build: {
      rollupOptions: {
        input: {
          index: path.resolve(process.cwd(), "index.html"),
          docs: path.resolve(process.cwd(), "docs.html"),
          labs: path.resolve(process.cwd(), "labs.html"),
          ...(buildWordproc
            ? { wordproc: path.resolve(process.cwd(), "wordproc.html") }
            : {}),
        },
      },
    },
    plugins: [
      {
        name: "solidus:ensure-dart-pub-get",
        configResolved() {
          ensureDartPubGet();
        },
      },
      Dart({
        dart,
        stdio: true,
        verbosity: "all",
      }),
    ],
  };
});
