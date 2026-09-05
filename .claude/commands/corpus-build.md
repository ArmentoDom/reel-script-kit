---
description: "Paste your reel links — this drives ChatGPT in Chrome to watch and analyze them, and sets up everything else"
argument-hint: "[--local] [--manual] [reel URLs, if you have them handy]"
---

# Build the corpus

This is the **setup command**. When it finishes, the user should be able to run
`/reel-script` and nothing else.

It does three things: collects their reels, drives ChatGPT in Chrome to actually
watch and analyze them, and interviews them about their own proof while that
runs. Two commands total for the whole kit — keep it that way. Do not send them
off to run something else in the middle.

Arguments: `$ARGUMENTS`

- default → the ChatGPT-in-Chrome lane, automated
- `--local` → local lane instead (yt-dlp + ffmpeg, see section 8)
- `--manual` → build the prompt and hand it over, no browser automation

## 1. Collect the reels

Read `corpus/reels.txt`. If it holds only the commented placeholders, **ask for
the URLs right here in the conversation.** Do not tell them to go edit a file.

Ask for the reels they saved because they **admired** them — not what went
viral, but what they would be proud to have made. Their taste is the input.

Get, briefly:
- the URLs,
- which creator each belongs to,
- one line per creator on why they saved them, in their own words. Capture this
  *before* any analysis, so the analysis cannot rationalize itself afterwards.

Tell them, in one short line each: 8–12 reels per creator, two or three
creators, 15–25 total — and that more than one creator matters because the
contrast between creators is what separates transferable structure from personal
style.

If they paste a big unlabeled block of links, do not interrogate them line by
line. Group what you can from the URLs themselves and ask one question to
confirm.

Write it all into `corpus/reels.txt` in the existing format (`# creator: Name`
headers, one URL per line), keeping the header comments intact.

## 2. Build the message

```bash
tools/chatgpt_message.sh
```

This concatenates the analyst prompt with their reel list and puts the whole
thing on the clipboard.

**Clipboard, not typing.** Typing into ChatGPT keystroke-by-keystroke does not
work here: Enter sends the message, so a multi-line prompt fires off in
fragments. Paste it as one message.

Check the reported URL count matches what they gave you. If it says 0, the write
in step 1 did not land — fix that before going further.

## 3. Open ChatGPT

```
tabs_context_mcp { createIfEmpty: true }
tabs_create_mcp                       ← always a fresh tab, never reuse theirs
navigate → https://chatgpt.com/
```

Screenshot. If they are not signed in, stop and ask them to sign in, then
continue — do not attempt to log in on their behalf.

Prefer a model that can browse and handle video. If a model picker is visible
and set to something basic, switch it to their most capable available model and
say which one you picked.

## 4. Paste and send

1. `find` the message composer, click it.
2. `computer` action `key`, text `cmd+v`.
3. **Screenshot and confirm the text actually landed** before sending. A failed
   paste that gets sent produces a confidently wrong conversation, and it is
   easy to miss.
4. Send with `key` → `Return`.

If the paste did not land, try clicking directly into the composer and pasting
again. If it still fails after two attempts, fall back to `--manual` (section 9)
rather than retrying indefinitely.

## 5. While it works — interview them

The analysis takes a while: it is retrieving and watching 15–25 videos. Use that
time instead of making them watch a spinner.

Tell them what is happening, then run the **voice interview** from
`/voice-setup` — read that command file and follow it. Produce
`voice/voice.json`.

This is why they never have to run `/voice-setup` separately. Cover the same
ground: identity, positioning (including the accounts they would hate to be
mistaken for), **proof** — the longest and most important part — audience, voice
rules, constraints, banned claims, and anything already published.

Be rigorous about `proof[]`. It is a closed list, and the script agent may only
make claims that trace into it. "I think it was around 10,000" is
`verified: false`. If they have no results yet, `evidence_type: "none_yet"` is a
legitimate answer and worth saying plainly.

Check back on the ChatGPT tab between batches of questions.

## 6. Collect the result

Poll the tab — screenshot or `get_page_text` — until the reply is complete.
Space the checks out; this can run for several minutes. Do not spam it.

Watch for:
- **it asking a question instead of working** → answer it and let it continue,
- **it stopping partway** → tell it to continue,
- **a "continue generating" button** → click it,
- **it claiming it cannot download a video** → note which, and carry on. Missing
  reels are fine. Invented ones are not.

When the JSON block is there, get it out via **the code block's copy button** —
click it, then:

```bash
pbpaste > corpus/corpus.json
```

That avoids the truncation you get from scraping page text. If there is no copy
button, fall back to `get_page_text` and extract the final fenced block, then
check the JSON is complete rather than cut off mid-structure.

## 7. Validate, check, and write corpus.md

```bash
node tools/validate.mjs corpus
```

If it fails, paste the exact errors back into the ChatGPT tab and ask for a
corrected full block. It repairs its own output well against specific errors.
Two rounds of that; if it is still failing, fix the remaining fields yourself
and say what you changed.

Then read the content, because a valid shape can still be wrong. Check:

- **Invented reels.** Does the entry count match the URLs actually retrieved?
  A model that could not fetch a video sometimes writes a plausible entry
  anyway. This is the failure to look for, every time.
- **Averaged creators.** Is `aggregate.per_creator` populated with genuinely
  different numbers, or were two creators collapsed into one house style?
- **Lessons that are skin, not grammar.** Any `lesson` that cannot be stated
  without naming that creator's topic needs rewriting.
- **Flattering engine risks.** A soft `risk_if_copied_wholesale` is useless.
- **Suspiciously precise numbers** from what was really an estimate.

Fix what you can, flag what needs their judgment.

Then write **`corpus/corpus.md`** from the JSON, following the section order in
`corpus/TEMPLATE_corpus.md` — tables for numbers, prose for judgment. Do not
skip this; it is the file they will actually read.

Close the tab you opened.

## 8. `--local` lane

If they passed `--local`, or ChatGPT is unavailable and `yt-dlp` + `ffmpeg` are
installed:

```bash
tools/corpus_fetch.sh
```

Downloads, measures duration and hard cuts, samples a frame per second. Then
spawn the Agent tool with `subagent_type: "corpus-analyst"`, giving it the
prepared ids, the creator grouping and each `why_saved` note verbatim. Still run
the voice interview from section 5. Then continue from section 7.

Note that downloads land in `corpus/raw/`, which is gitignored: other people's
videos stay local, and the analysis is what gets committed.

## 9. `--manual` lane

Run `tools/chatgpt_message.sh`, tell them it is on their clipboard, and to paste
it into ChatGPT and bring back the JSON block. Then run `/corpus-import`. Still
do the voice interview.

## 10. Report

Lead with the **per-creator pacing contrast** — it is the headline finding.
Then the visual modes, and quote each engine's `risk_if_copied_wholesale`
directly; those are the most useful sentences in the document and the easiest to
skim past.

Say plainly what was excluded and why.

Then two things:

> Read `corpus/corpus.md` and edit it. The machine measured; you judge. Where
> you disagree, write it in — that disagreement is your taste.

> Everything is set up. Next: `/reel-script <slug> <your idea>`
