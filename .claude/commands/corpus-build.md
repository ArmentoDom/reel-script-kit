---
description: "Build my reference corpus from the reels I admire — download, analyze, write corpus.json"
argument-hint: "[--browser] [reel URLs, if I have not filled in reels.txt yet]"
---

# Build the corpus

Turn the reels the user admires into a structured record of their taste.

Arguments: `$ARGUMENTS`

## 1. Collect the URLs

Read `corpus/reels.txt`.

**If it has no real URLs** (only the commented examples), ask for them right
here in the conversation. Do not make them go and edit a file first — this is
the moment they are ready to give you the list.

Ask for the reels they saved because they **admired** them — not reels that went
viral, but ones they would be proud to have made. Their taste is the input.

Ask which creator each belongs to, and get a one-line `why_saved` in their own
words for each creator. Capture that note *before* any analysis, so the analysis
cannot rationalize itself after the fact.

Guidance to give them, briefly: 8–12 reels per creator, two or three creators,
15–25 total. Explain why more than one creator matters — the contrast between
creators is what separates transferable structure from personal style. One
creator gives you an impression; three give you a grammar.

Write everything into `corpus/reels.txt` in the existing format
(`# creator: Name` group headers, one URL per line), preserving the header
comments.

## 2. Pick a lane

Run `node tools/doctor.mjs` and look at the toolchain.

**Local lane** (default when `yt-dlp`, `ffmpeg` and `ffprobe` are all present):
everything runs on this machine, nothing is uploaded, and the measured numbers
come from the actual video files.

**Browser lane** (`--browser`, or when the local tools are missing, or for
reels that are login-gated): hand the ChatGPT prompt over instead. Skip to
section 5.

If the local tools are missing, offer `brew install yt-dlp ffmpeg` (a one-time
install, and the better path), but do not insist — the browser lane is a real
alternative, not a fallback for people who did something wrong.

## 3. Download and prepare

```bash
tools/corpus_fetch.sh
```

This downloads each reel, measures duration and hard cuts, samples a frame per
second, and extracts audio — writing `corpus/frames/<id>/meta.json` for each.

Report what came back. Some URLs will fail — private, deleted, or login-gated —
and that is normal and not a problem: analysis runs on whatever downloaded.
If **more than half** fail, stop and say so rather than building a corpus on
four reels; suggest the browser lane for the ones that would not come down.

Downloads land in `corpus/raw/`, which is gitignored. Mention this once: those
are other people's copyrighted videos, kept locally to study and never
committed or published. The analysis is what gets committed, because the
analysis is theirs.

## 4. Analyze

Spawn the Agent tool with `subagent_type: "corpus-analyst"`. Tell it:

- the prepared reel ids and where their frames and `meta.json` live,
- the creator grouping and each `why_saved` note verbatim,
- to write `corpus/corpus.json` and `corpus/corpus.md`,
- to keep per-creator aggregates separate and never average two creators'
  pacing into one number,
- to validate its own output before finishing.

This reads a lot of frames and takes a few minutes. Say so before starting.

Then skip to section 6.

## 5. Browser lane

Two ways to run it, user's choice:

**Hands-off** — if the `claude-in-chrome` tools are available and the user
wants it driven: open a new tab on ChatGPT, paste the prompt from
`corpus/prompts/chatgpt-corpus-analyst.md`, paste the URLs when it asks, let it
work, and collect the JSON block it returns. Watch for it stalling on a
download it cannot do, and do not let it invent an entry for a reel it never
retrieved — that is the specific failure to check for.

**Manual** — print the prompt file's location, tell them to paste it into
ChatGPT along with their URLs, and to bring back the JSON block. Then run
`/corpus-import`.

Either way the result goes to `corpus/corpus.json`, then:

```bash
node tools/validate.mjs corpus
```

If it fails, paste the errors back to ChatGPT — it repairs its own output well
against specific reported problems.

Then produce `corpus/corpus.md` from the JSON, following the section order in
`corpus/TEMPLATE_corpus.md`.

## 6. Report

Show them:

- how many reels made it in, and any that were excluded and why,
- the per-creator pacing contrast — this is the headline finding, lead with it,
- the visual modes that were identified,
- the `risk_if_copied_wholesale` line for each engine, quoted directly. These
  are the most useful sentences in the whole document and the easiest to skim
  past.
- the synthesized positioning statement and script formula.

Then tell them plainly: **read `corpus/corpus.md` and edit it.** The machine
measured; they judge. Their disagreements with the analysis are signal, and a
corpus they have argued with is worth more than one they accepted.

Next step: `/voice-setup` if `voice/voice.json` does not exist yet, otherwise
`/reel-script <slug> <idea>`.
