import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";

function formatBytes(bytes) {
  const units = ["B", "KB", "MB", "GB"];
  let n = bytes;
  let i = 0;
  while (n >= 1024 && i < units.length - 1) {
    n /= 1024;
    i++;
  }
  return `${n.toFixed(i === 0 ? 0 : 1)}${units[i]}`;
}

function walkFiles(dir) {
  const out = [];
  const stack = [dir];
  while (stack.length) {
    const current = stack.pop();
    if (!current) continue;
    const entries = fs.readdirSync(current, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) stack.push(full);
      else if (entry.isFile()) out.push(full);
    }
  }
  return out;
}

function gzipSize(buf) {
  return zlib.gzipSync(buf).length;
}

function brotliSize(buf) {
  return zlib.brotliCompressSync(buf, {
    params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 11 },
  }).length;
}

function padLeft(s, n) {
  const str = String(s);
  return str.length >= n ? str : " ".repeat(n - str.length) + str;
}

function main() {
  const root = process.cwd();
  const dist = path.join(root, "dist");
  const assets = path.join(dist, "assets");

  if (!fs.existsSync(dist)) {
    console.error(`Missing dist/. Run: npm run build`);
    process.exit(2);
  }

  const files = walkFiles(dist)
    .filter((f) => !f.endsWith(path.sep + ".DS_Store"))
    .map((f) => ({
      abs: f,
      rel: path.relative(dist, f).replaceAll(path.sep, "/"),
    }));

  const rows = [];
  for (const f of files) {
    const buf = fs.readFileSync(f.abs);
    const ext = path.extname(f.abs).toLowerCase();
    const include = [".js", ".css", ".html", ".json", ".svg"].includes(ext);
    rows.push({
      file: f.rel,
      ext,
      raw: buf.length,
      gzip: include ? gzipSize(buf) : null,
      br: include ? brotliSize(buf) : null,
    });
  }

  rows.sort((a, b) => b.raw - a.raw);

  const inAssets = (r) => r.file.startsWith("assets/");
  const sums = (rs) => ({
    raw: rs.reduce((n, r) => n + r.raw, 0),
    gzip: rs.reduce((n, r) => n + (r.gzip ?? 0), 0),
    br: rs.reduce((n, r) => n + (r.br ?? 0), 0),
  });

  const all = sums(rows);
  const onlyAssets = sums(rows.filter(inAssets));
  const jsCss = rows.filter((r) => r.ext === ".js" || r.ext === ".css");
  const jsCssSums = sums(jsCss);

  console.log(`dist: ${dist}`);
  console.log(`assets: ${fs.existsSync(assets) ? assets : "(missing)"}`);
  console.log("");
  console.log(
    [
      "file",
      padLeft("raw", 10),
      padLeft("gzip", 10),
      padLeft("br", 10),
    ].join("  "),
  );
  console.log("-".repeat(80));

  const top = rows.slice(0, 25);
  for (const r of top) {
    console.log(
      [
        r.file.padEnd(44),
        padLeft(formatBytes(r.raw), 10),
        padLeft(r.gzip == null ? "-" : formatBytes(r.gzip), 10),
        padLeft(r.br == null ? "-" : formatBytes(r.br), 10),
      ].join("  "),
    );
  }

  console.log("-".repeat(80));
  const summaryLine = (label, s) =>
    `${label.padEnd(16)}  raw ${padLeft(formatBytes(s.raw), 8)}  gzip ${padLeft(
      formatBytes(s.gzip),
      8,
    )}  br ${padLeft(formatBytes(s.br), 8)}`;

  console.log(summaryLine("TOTAL", all));
  console.log(summaryLine("dist/assets/*", onlyAssets));
  console.log(summaryLine("JS+CSS only", jsCssSums));
}

main();

