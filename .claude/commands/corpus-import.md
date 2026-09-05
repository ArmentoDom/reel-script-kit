---
description: "Import a corpus analysis produced in ChatGPT (browser lane) and validate it"
argument-hint: "[path to a saved .json file, or paste the JSON when asked]"
---

# Import a corpus

Take the JSON block ChatGPT produced and turn it into a validated
`corpus/corpus.json` plus a readable `corpus/corpus.md`.

Arguments: `$ARGUMENTS`

## 1. Get the JSON

If a file path was given, read it. Otherwise ask the user to paste the block —
they can paste the whole reply including the prose; extract the final fenced
```json block from it.

If `corpus/corpus.json` already exists, show a one-line summary of what is
there and ask whether to replace it or bump `corpus_version` and keep the old
one alongside. Never silently overwrite an existing corpus.

## 2. Validate and repair

Write it to `corpus/corpus.json`, then:

```bash
node tools/validate.mjs corpus
```

Fix what you can yourself — missing `method` (set `chatgpt_browser`), missing
`built_at`, obvious structural slips.

Do **not** invent content to satisfy a `minItems` or `minLength` rule. If the
analysis genuinely came back with two visual modes where the schema wants
three, that is a real finding about a thin analysis, not a formatting problem.
Tell the user, and offer either to send the specific errors back to ChatGPT or
to fill the gap together from what they know about the reels.

## 3. Sanity-check the content

Validation only proves the shape is right. Read it and check for the failures
that pass a schema cleanly:

- **Invented reels.** Does the reel count match the URLs actually supplied? An
  entry for a video the model could not retrieve is the most common and most
  damaging failure in this lane.
- **Averaged creators.** Is `aggregate.per_creator` populated with genuinely
  different numbers, or did it collapse two creators into one house style?
- **Lessons that are skin, not grammar.** Any `lesson` that cannot be stated
  without naming that creator's specific topic needs rewriting.
- **Flattering engine risks.** If `risk_if_copied_wholesale` is soft or
  complimentary, it is useless. Push for the blunt version.
- **Suspiciously precise numbers.** Word counts reconstructed from captions are
  estimates and should read like it.

Raise anything you find. You are the second reader here, and this is the step
that catches what the first pass got wrong.

## 4. Write corpus.md

Generate the readable document from the JSON, following the section order in
`corpus/TEMPLATE_corpus.md`. Tables for numbers, prose for judgment.

## 5. Report

Summarize what came in, what you fixed, and anything you flagged. Then point
them at `corpus/corpus.md` to read and edit — the machine measured, they judge.

Next: `/voice-setup` if there is no `voice/voice.json`, otherwise
`/reel-script <slug> <idea>`.
