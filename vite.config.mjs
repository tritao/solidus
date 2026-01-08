import fs from "node:fs";
import fsp from "node:fs/promises";
import path from "node:path";
import { defineConfig, loadEnv } from "vite";
import Dart from "vite-plugin-dart";

function serveRepoAssets() {
  const root = process.cwd();
  const assetsRoot = path.join(root, "assets");

  const contentTypeFor = (filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    switch (ext) {
      case ".json":
        return "application/json; charset=utf-8";
      case ".html":
        return "text/html; charset=utf-8";
      case ".png":
        return "image/png";
      case ".svg":
        return "image/svg+xml";
      case ".css":
        return "text/css; charset=utf-8";
      case ".js":
        return "application/javascript; charset=utf-8";
      default:
        return "application/octet-stream";
    }
  };

  const safeJoin = (base, rel) => {
    const joined = path.join(base, rel);
    const normalizedBase = path.resolve(base) + path.sep;
    const normalized = path.resolve(joined);
    if (!normalized.startsWith(normalizedBase)) return null;
    return normalized;
  };

  return {
    name: "serve-repo-assets",
    apply: "serve",
    configureServer(server) {
      // Serve repo-local `assets/` at `/assets/*` (Vite otherwise treats `/assets`
      // as a special path and falls back to index.html).
      server.middlewares.use("/assets", async (req, res, next) => {
        try {
          if (!req.url) return next();
          if (req.method !== "GET" && req.method !== "HEAD") return next();

          const url = new URL(req.url, "http://localhost");
          let relPath = url.pathname;
          // Depending on middleware mounting semantics, pathname might still
          // include the "/assets" prefix. Handle both cases.
          if (relPath.startsWith("/assets/")) relPath = relPath.slice("/assets/".length);
          relPath = relPath.replace(/^\/+/, "");
          const filePath = safeJoin(assetsRoot, relPath);
          if (!filePath) return next();

          const stat = await fsp.stat(filePath).catch(() => null);
          if (!stat || !stat.isFile()) return next();

          res.statusCode = 200;
          res.setHeader("Content-Type", contentTypeFor(filePath));
          res.setHeader("Cache-Control", "no-cache");
          const data = await fsp.readFile(filePath);
          res.end(data);
        } catch {
          next();
        }
      });
    },
  };
}

function copyRepoAssets() {
  let resolvedOutDir = null;
  return {
    name: "copy-repo-assets",
    apply: "build",
    configResolved(config) {
      resolvedOutDir = config?.build?.outDir ?? "dist";
    },
    async writeBundle() {
      const root = process.cwd();
      const assetsRoot = path.join(root, "assets");
      const outDir =
        resolvedOutDir && path.isAbsolute(resolvedOutDir)
          ? resolvedOutDir
          : path.join(root, resolvedOutDir ?? "dist");

      const srcDocs = path.join(assetsRoot, "docs");
      const destAssets = path.join(outDir, "assets");
      const destDocs = path.join(destAssets, "docs");
      await fsp.mkdir(destAssets, { recursive: true });
      await fsp.rm(destDocs, { recursive: true, force: true });

      if (fs.existsSync(srcDocs)) {
        const copyDir = async (src, dest) => {
          await fsp.mkdir(dest, { recursive: true });
          const entries = await fsp.readdir(src, { withFileTypes: true });
          for (const entry of entries) {
            const from = path.join(src, entry.name);
            const to = path.join(dest, entry.name);
            if (entry.isDirectory()) {
              await copyDir(from, to);
            } else if (entry.isFile()) {
              await fsp.mkdir(path.dirname(to), { recursive: true });
              await fsp.copyFile(from, to);
            }
          }
        };
        await copyDir(srcDocs, destDocs);
      }

      // Copy any top-level files under assets/ into dist/assets/.
      if (fs.existsSync(assetsRoot)) {
        const entries = await fsp.readdir(assetsRoot, { withFileTypes: true });
        for (const entry of entries) {
          if (!entry.isFile()) continue;
          await fsp.copyFile(
            path.join(assetsRoot, entry.name),
            path.join(destAssets, entry.name),
          );
        }
      }
    },
  };
}

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

  return {
    base,
    build: {
      rollupOptions: {
        input: {
          index: path.resolve(process.cwd(), "index.html"),
          wordproc: path.resolve(process.cwd(), "wordproc.html"),
        },
      },
    },
    plugins: [
      serveRepoAssets(),
      copyRepoAssets(),
      Dart({
        dart,
        stdio: true,
        verbosity: "all",
      }),
    ],
  };
});
