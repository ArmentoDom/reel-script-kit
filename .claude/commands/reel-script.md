---
description: "Write a spoken script from an idea, in my voice, built on my corpus"
argument-hint: "<video-slug> <idea, topic, link, or rough thought>"
---

# Script — agent `reel-script`

Arguments: `$ARGUMENTS` — the first token is the video slug; everything after
it is the idea.

## 1. Gate check — do not skip

Both files are required. This agent's entire job is to sound like a specific
person working from a specific taste, and without them it would be guessing.

- `voice/voice.json` missing → stop, tell them to run `/voice-setup`.
- `corpus/corpus.json` missing → stop, tell them to run `/corpus-build`.

Run `node tools/validate.mjs all` and report any failures before going further.
A malformed `voice.json` produces a subtly wrong script rather than an obvious
error, which is worse.

## 2. Resolve the project

Project dir is `projects/<slug>/`.

- No slug given → propose one from the idea (kebab-case, short) and confirm it.
- Create the directory if needed. This is the only command that creates one.
- `script.json` already there → say so and ask whether to revise or start a new
  project. Never silently overwrite.

## 3. Get a real idea

If no idea was supplied and none is obvious from the conversation, **ask**.
Do not pick a topic on someone's behalf.

If they say "what should my next video be about," that is a legitimate request —
but answer it from their own material: read `voice.json` `proof[]` for what they
can uniquely back up, check `used_hooks` for what is already spent, and propose
three specific angles for them to choose from. Then write the one they pick.

## 4. Run the agent

Spawn the Agent tool with `subagent_type: "reel-script"`. Give it:

- the project dir and the idea **verbatim** — do not paraphrase the user's
  framing, it usually carries the angle,
- that it controls **words only** — no visuals, camera, graphics or timing,
- that every factual claim must trace to a `voice.json` `proof[]` entry via
  `proof_ref`, or carry `needs_verification`,
- any extra instruction the user included.

## 5. Report back

Show the hook and the beat structure, and state:

- the concrete takeaway,
- which engine's grammar it leaned on and why (`corpus_lean`),
- the word budget arithmetic against `target_wpm` and runtime,
- every `[NEEDS VERIFICATION]` flag and every claim whose proof does not exist
  yet — call these out prominently rather than burying them,
- the `self_check` results, including anything that came back false.

Confirm `script.json` validates.

Then:

> 🛑 **HUMAN GATE** — read `script.md` and approve or edit it before anything
> else happens.

## 6. After approval

When they approve and publish, append the hook to `voice.used_hooks` and the
CTA to `voice.used_ctas` so a future run cannot repeat them. Ask before writing;
do not treat "looks good" on a draft as confirmation that it shipped.
