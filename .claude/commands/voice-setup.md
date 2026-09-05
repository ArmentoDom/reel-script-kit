---
description: "Interview me and build voice/voice.json — who I am, what I can prove, how I'm allowed to sound"
argument-hint: "(no arguments)"
---

# Voice setup

Build `voice/voice.json` by **interviewing the user directly, in this
conversation**. Do not spawn a subagent — a subagent cannot talk to them, and
the answers are the entire point.

If `voice/voice.json` already exists, show a summary and ask whether to revise
it or start over. Never silently overwrite it.

## How to run the interview

Ask in small batches — two or three questions at a time, conversationally.
This should feel like a good intake call, not a form. Roughly 5–10 minutes.

Use `AskUserQuestion` where there are discrete options
(`cta_style`, `humor`, `profanity`, `person`), and plain conversation where the
answer is prose.

Read `voice/voice.example.json` first so you know the target shape, and
`schemas/voice.schema.json` for the contract.

## What you need to come away with

**Identity.** Name, handle, and the one sentence a stranger could read to know
why this person is worth listening to.

**Positioning.** The two to four things they sit at the intersection of. Then —
harder and more valuable — the nearby accounts they would hate to be mistaken
for. Push on this one. Most people answer the positive question easily and have
never articulated the negative, and the negative is what actually makes the
script agent's judgment sharp later.

**Proof.** The heart of the file, and the part to spend the most time on. Walk
through everything they can genuinely back up: shipped things, numbers,
rankings, revenue, credentials, artifacts, testimonials. For each one get the
claim, what *kind* of evidence exists, where it lives, and whether they have
personally confirmed it is accurate and current.

Be gently rigorous here. "I think it was around 10,000" is `verified: false`.
Something true two years ago that they have not rechecked gets an `expires`
date. This list is a closed set — the script agent may only make claims that
trace into it — so an inflated entry becomes a false claim in a published
video, and a missing entry only costs one follow-up question.

If someone has genuinely no proof yet, that is workable and worth saying out
loud: record `evidence_type: "none_yet"`, and note that their early scripts
should lean on teaching and honest process rather than results claims. That is
a real position, not a deficiency.

**Audience.** Who they are for, what those people want, and — the one people
get wrong — what the audience *already knows*. This sets the floor for how much
gets explained. Explaining below the floor is the most common reason a
well-researched script is boring.

**Voice rules.** Phrasings that sound like them. Then the bans: filler,
guru-isms, anything borrowed from a creator in their corpus, anything that makes
them wince. Seed `never_say` with a few obvious ones if they draw a blank, but
get at least one that is genuinely theirs.

**Constraints.** Target words per minute and typical runtime — pull the
defaults from `corpus/corpus.json` `pacing_targets` if it exists, and confirm
rather than asking cold. CTA style. And the resource offer: if they pick a
comment-keyword CTA, ask what the keyword actually delivers. **If it does not
exist yet, leave `resource_offer` empty and tell them plainly** that a CTA
promising a resource they have not built is the fastest way to lose a new
audience. Better a positioning CTA now and a real offer later.

**Banned claims.** Things that are true but they have decided not to say —
income, employer, clients, NDA, or simply taste.

**Already used.** Any hook or CTA already published, so the agent cannot repeat
it.

## Finish

1. Write `voice/voice.json` (drop the `_note` field from the example).
2. Run `node tools/validate.mjs voice` and fix anything it reports.
3. Show a short summary — positioning, proof count, how many verified vs not.
4. Say what is next:
   - no `corpus/corpus.json` yet → `/corpus-build`
   - corpus exists → `/reel-script <slug> <idea>`

Then remind them, in one line, that `voice.json` is a living file: proof gets
added as they ship, and `used_hooks` grows with every published video.
