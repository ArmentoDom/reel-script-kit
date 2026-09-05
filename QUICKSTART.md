# Quickstart

Clone, run two commands, get a script. About 20 minutes, most of it spent
answering questions about yourself while ChatGPT watches your reels.

## 1. Open it

```bash
git clone <your-fork> reel-script-kit
cd reel-script-kit
claude
```

Nothing to install. No API keys. No files to edit first.

## 2. `/corpus-build`

It asks for your reel links right in the conversation. Paste them in.

**Choosing which reels is the highest-leverage thing you do here.** Pick the ones
you saved because you *admired* them, not the ones that went viral — different
things. Your taste is the input, and borrowed taste produces borrowed scripts.

Use two or three creators, 8–12 reels each. More than one creator is not
optional: with a single creator you cannot tell which parts are structure and
which are personality. A second one separates them immediately. One creator
gives you an impression; three give you a grammar.

Then it takes over:

1. Opens Chrome and starts a ChatGPT conversation.
2. Pastes a long analyst prompt with your links, and sends it.
3. ChatGPT retrieves and **actually watches** each reel — measuring duration,
   cuts, pacing, and reading the structure.
4. Meanwhile, it interviews *you* — five minutes, answered in the same chat.
5. Brings the analysis back, validates it, checks it for invented entries, and
   writes everything to disk.

### The interview

Answer honestly rather than impressively. This file is the guardrail that stops
the agent inventing results on your behalf.

The part that matters most is **proof**: everything you can genuinely back up.
Be strict. "I think it was around 10,000" should be marked unverified — it costs
you nothing and an inflated entry becomes a false claim in a published video.

No results yet? Say so. That is recorded as `none_yet`, and your early scripts
lean on teaching and honest process instead of results claims. That is a real
position, often a more durable one than borrowed authority.

### When it finishes

You have `corpus/corpus.json`, `corpus/corpus.md`, and `voice/voice.json`.
Setup is done — there is no third command.

## 3. Read `corpus.md` and argue with it

The one step worth not skipping.

Read the per-creator pacing contrast, the visual modes, and especially each
engine's **risk if copied wholesale** — the sentence saying what would go wrong
if you copied that creator straight.

Where you disagree, edit the file. The machine measured; you know why you saved
those reels. A corpus you have argued with is worth several times one you
accepted unread.

## 4. `/reel-script`

```
/reel-script my-first-video the thing I cannot stop explaining to people
```

You get `script.md` to read and perform, and `script.json` for the stages
downstream.

Check the flagged claims. Anything marked `[NEEDS VERIFICATION]` is the agent
telling you it could not trace that claim to your proof list — get the evidence
or cut the claim. Do not publish past that flag.

Then it stops and waits for you to approve.

## Afterwards

`voice.json` is a living file: add proof as you ship, and published hooks and
CTAs get recorded so the agent cannot repeat them.

Rebuild the corpus when your taste moves — after twenty or thirty videos it will
have. Keep the old `corpus.md`; the v1→v2 diff is one of the more interesting
things this produces.

## If something goes wrong

`/reel-doctor` tells you what is set up and what to do next.

- **ChatGPT could not fetch some reels** — normal. Analysis runs on the rest.
  If most failed, try again with a signed-in ChatGPT session.
- **You would rather not use ChatGPT** — `brew install yt-dlp ffmpeg`, then
  `/corpus-build --local` does everything on your own machine.
- **You want to run ChatGPT yourself** — `/corpus-build --manual` puts the
  prompt on your clipboard; bring the JSON back with `/corpus-import`.
