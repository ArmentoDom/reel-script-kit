#!/usr/bin/env node
/**
 * Health check. Tells you exactly which lane you can run and what is missing.
 * Zero dependencies.
 *   node tools/doctor.mjs
 */
import { execSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const has = (bin) => {
  try { execSync(`command -v ${bin}`, { stdio: "ignore" }); return true; } catch { return false; }
};
const read = (p) => { try { return JSON.parse(readFileSync(join(ROOT, p), "utf8")); } catch { return null; } };

const mark = (ok) => (ok ? "ok  " : "--  ");
const out = [];
const say = (s) => out.push(s);

say("");
say("  REEL SCRIPT KIT - doctor");
say("  " + "-".repeat(46));

// ---- toolchain ----
const ytdlp = has("yt-dlp"), ffmpeg = has("ffmpeg"), ffprobe = has("ffprobe");
const localLane = ytdlp && ffmpeg && ffprobe;

say("");
say("  Toolchain");
say(`   ${mark(true)} node        ${process.version}`);
say(`   ${mark(ytdlp)} yt-dlp      ${ytdlp ? "installed" : "missing - needed for the local lane"}`);
say(`   ${mark(ffmpeg)} ffmpeg      ${ffmpeg ? "installed" : "missing - needed for the local lane"}`);
say(`   ${mark(ffprobe)} ffprobe     ${ffprobe ? "installed" : "missing - needed for the local lane"}`);

// ---- inputs ----
const listPath = join(ROOT, "corpus/reels.txt");
let urls = 0, creators = new Set();
if (existsSync(listPath)) {
  for (const raw of readFileSync(listPath, "utf8").split("\n")) {
    const l = raw.trim();
    const m = l.match(/^#\s*creator:\s*(.+)$/i);
    if (m) creators.add(m[1].trim());
    else if (/^https?:\/\//.test(l)) urls++;
  }
}

const downloaded = (() => {
  const raw = join(ROOT, "corpus/raw");
  if (!existsSync(raw)) return 0;
  let n = 0;
  for (const d of readdirSync(raw)) {
    const sub = join(raw, d);
    try { n += readdirSync(sub).filter((f) => f.endsWith(".mp4")).length; } catch {}
  }
  return n;
})();

const analyzed = (() => {
  const f = join(ROOT, "corpus/frames");
  if (!existsSync(f)) return 0;
  return readdirSync(f).filter((d) => existsSync(join(f, d, "meta.json"))).length;
})();

say("");
say("  Your inputs");
say(`   ${mark(urls > 0)} reels.txt   ${urls} URL(s) across ${creators.size || 0} creator group(s)`);
say(`   ${mark(downloaded > 0)} downloaded  ${downloaded} reel(s) in corpus/raw/`);
say(`   ${mark(analyzed > 0)} prepared    ${analyzed} reel(s) with frames + meta.json`);

// ---- artifacts ----
const voice = read("voice/voice.json");
const corpus = read("corpus/corpus.json");

say("");
say("  Your taste");
say(`   ${mark(!!voice)} voice.json  ${voice ? `${voice?.owner?.name ?? "unnamed"} · ${voice?.proof?.length ?? 0} proof entr(ies) · ${voice?.used_hooks?.length ?? 0} hook(s) used` : "not created - run /voice-setup"}`);
say(`   ${mark(!!corpus)} corpus.json ${corpus ? `${corpus?.reels?.length ?? 0} reel(s) · ${corpus?.visual_modes?.length ?? 0} mode(s) · v${corpus?.corpus_version ?? "?"}` : "not created - run /corpus-build"}`);

const projects = (() => {
  const p = join(ROOT, "projects");
  if (!existsSync(p)) return [];
  return readdirSync(p).filter((d) => existsSync(join(p, d, "script.json")));
})();
say(`   ${mark(projects.length > 0)} scripts     ${projects.length} written`);

// ---- verdict ----
say("");
say("  " + "-".repeat(46));
const ready = !!voice && !!corpus;
if (ready) {
  say("  READY.  Write your next script:  /reel-script <slug> <idea>");
} else {
  say("  Next step:");
  if (!voice) say("    1. /voice-setup      - takes about 5 minutes, answer honestly");
  if (!corpus) {
    if (urls === 0)      say("    2. Add reel URLs to corpus/reels.txt, then /corpus-build");
    else if (!localLane) say("    2. /corpus-build     - will use the browser lane (yt-dlp/ffmpeg missing)");
    else                 say("    2. /corpus-build     - local lane ready");
  }
}

if (!localLane) {
  say("");
  say("  Local lane unavailable. Either install the tools:");
  say("     brew install yt-dlp ffmpeg");
  say("  or run /corpus-build and choose the browser lane, which needs no installs.");
}
say("");

console.log(out.join("\n"));
