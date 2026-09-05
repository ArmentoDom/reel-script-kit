# Quickstart

From clone to your first script. About 20 minutes, most of it thinking rather
than typing.

## 0. Optional but recommended (2 min)

```bash
brew install yt-dlp ffmpeg
```

Enables the local lane: everything runs on your machine, and the pacing numbers
come from the real video files rather than from a model's estimate. Skip it and
`/corpus-build --browser` uses ChatGPT instead.

## 1. Open the project

```bash
cd reel-script-kit
claude
```

```
/reel-doctor
```

Tells you what is present, what is missing, and the one next thing to do.

## 2. Voice setup (5 min)

```
/voice-setup
```

An interview. Answer honestly rather than impressively — this file is the
guardrail that stops the agent inventing results on your behalf.

The section that matters most is **proof**: everything you can genuinely back
up. Be strict. "I think it was around 10,000" is not verified, and marking it
so costs you nothing. An inflated entry here becomes a false claim in a
published video.

If you have no results yet, say so. `evidence_type: "none_yet"` is a legitimate
answer and the agent will lean on teaching and honest process instead. That is
a real position, not a deficiency.

## 3. Build your corpus (10 min, mostly waiting)

```
/corpus-build
```

It asks for your reel URLs directly — no file editing first.

**Choosing reels is the highest-leverage thing you will do here.** Pick the ones
you saved because you *admired* them, not the ones that went viral. Your taste
is the input; borrowed taste produces borrowed scripts.

Use two or three creators, 8–12 reels each. More than one creator is not
optional — the contrast between them is what separates transferable structure
from personal style. One creator gives you an impression. Three give you a
grammar.

Then it downloads, measures, and reads every reel frame by frame.

## 4. Argue with the result

```
open corpus/corpus.md
```

Do not skip this. The machine measured; you judge.

Read the per-creator pacing contrast, the visual modes, and especially each
engine's **risk if copied wholesale**. Where you disagree, edit the file — your
disagreement *is* your taste, and a corpus you have argued with is worth several
times one you accepted unread.

## 5. Write

```
/reel-script my-first-video the thing I cannot stop explaining to people
```

You get `script.md` to read and `script.json` for the stages downstream.

Check the flagged claims. Anything marked `[NEEDS VERIFICATION]` is the agent
telling you it could not trace a claim to your proof list — either get the
evidence or cut the claim. Do not publish past that flag.

## 6. Keep it current

`voice.json` is a living file. Add proof as you ship. When a script goes live,
its hook and CTA get recorded so the agent cannot repeat them.

Rebuild the corpus when your taste moves — after twenty or thirty videos, it
will have. The diff between v1 and v2 is one of the more interesting things
this produces.
