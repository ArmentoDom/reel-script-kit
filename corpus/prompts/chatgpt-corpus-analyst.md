# ChatGPT Corpus Analyst — paste-in prompt

Use this when you would rather not install anything, or when a reel is
login-gated and `yt-dlp` cannot reach it. Open a ChatGPT conversation with file
upload and video analysis available, paste **everything below the line**, then
paste your reel URLs when it asks.

When it returns the JSON block, save it as `corpus/corpus.json` and run:

```bash
node tools/validate.mjs corpus
```

If validation fails, paste the errors straight back into ChatGPT — it can
repair its own output against the reported problems.

---

You are a short-form video analyst. At the end of this message is a set of
Reel / Short / TikTok URLs from two or three creators whose work I admire. Your job is
to reverse-engineer the *transferable grammar* behind them, so that I can build
my own videos on the same structural principles without imitating anyone's
surface style.

## How to work

1. **Download and actually watch each video.** Do not analyze from the
   thumbnail, the caption, the title, or the comments. If you cannot retrieve a
   video, say so explicitly and continue with the rest — never guess at a
   video's contents and never invent an entry to fill a gap.
2. For each video, measure what can be measured: duration, spoken word count,
   words per minute, and the number of hard cuts or large compositional
   changes. State plainly that the cut count is a floor — it undercounts
   caption swaps, progressive reveals and micro-motion.
3. Normalize obvious transcription errors for product and person names, but
   flag that exact spelling still needs checking before anyone repeats it.
4. **Keep the creators separate.** Do not average two creators with different
   pacing into a single house number. If one runs 30-second proof videos and
   another runs 100-second teaching videos, that difference is the single most
   useful finding in the whole exercise — collapsing it destroys it.

## What to produce

Work through these in order, and show your reasoning in prose before the final
JSON:

1. **Corpus at a glance** — a per-creator table: videos, total runtime, median
   duration, spoken words, weighted words-per-minute, detected scenes, average
   scene length. Then say in one paragraph what the numbers alone reveal.
2. **Shared grammar** — what *every* video does regardless of creator. These are
   the closest thing to laws. Aim for 6-10.
3. **The differences** — a table of dimensions where the creators diverge
   (length, pacing, creator presence, visual surface, hook type, source of
   authority, CTA style). For each, name which side is right *for me* and why.
4. **Each creator's engine** — the repeatable beat sequence behind their videos,
   as an ordered list. Then, for each: its genuine strength, and — this part
   matters most — the specific **risk of copying it wholesale**. Every strong
   creator's engine has a failure mode when worn by someone who has not earned
   it. Name it bluntly.
5. **Visual modes** — the small, closed set of presentation modes these videos
   actually use (typically 4-6). Give each a `SCREAMING_SNAKE` key, its
   composition, what it is *for*, and what it must *not* be used for. The
   insight to preserve: these videos feel varied because modes are **sequenced**
   differently, not because every sentence gets a new design.
6. **Mode selection rules** — a lookup table from spoken beat ("a named tool is
   introduced", "an exact number is claimed", "a contrarian reversal") to the
   default mode. This is what stops visual choice from being re-argued line by
   line.
7. **Pacing targets** — derived from the measured numbers, stated as starting
   guardrails rather than laws.
8. **Typography and motion hierarchy** — the distinct text roles observed, and
   motion ordered from most to least meaningful.
9. **Anti-patterns** — what the corpus shows I should *not* do. Be specific and
   unsparing; this section is usually more useful than the positive rules.
10. **Reel-by-reel table** — one row each: id, topic, beat structure, dominant
    visual behavior, and the single transferable lesson. Test each lesson: if
    you cannot state it without naming that creator's specific topic, you have
    described the skin rather than the grammar. Rewrite it until you can.
11. **Synthesis** — the point of all of it. Not "imitate creator A" but a named
    combination: what I take from each, what I explicitly leave behind, a
    positioning statement, and a default beat formula for my own scripts.

## Rules

- Steal the grammar, never the skin. Sequence, timing and structure transfer.
  Phrasing, color palette, catchphrases and personality do not.
- Never fabricate a number. If you could not measure something, write `null` and
  say why.
- Be blunt about weaknesses. A corpus that flatters these creators is useless to
  me — I need to know where copying them would make me look derivative or
  unearned.
- Do not reproduce anyone's script verbatim. Quote at most a short phrase, and
  only when the exact wording is the point being analyzed.

## Final output

After the prose, output a single fenced ```json block, and nothing after it,
conforming exactly to this shape:

```json
{
  "corpus_version": 1,
  "built_at": "<ISO date>",
  "method": "chatgpt_browser",
  "sources": [{ "creator": "", "handle": "", "reel_count": 0, "why_saved": "" }],
  "reels": [{
    "id": "", "creator": "", "url": "", "duration_sec": 0,
    "word_count": 0, "wpm": 0, "scene_count": 0, "avg_scene_sec": 0,
    "topic": "", "content_structure": [""], "dominant_visual_behavior": "",
    "hook_type": "", "cta_type": "", "lesson": ""
  }],
  "aggregate": {
    "total_runtime_sec": 0, "median_duration_sec": 0, "weighted_wpm": 0, "avg_scene_sec": 0,
    "per_creator": [{ "creator": "", "videos": 0, "total_runtime_sec": 0,
                      "median_duration_sec": 0, "weighted_wpm": 0, "avg_scene_sec": 0 }]
  },
  "engines": [{ "creator": "", "steps": [""], "strength": "", "risk_if_copied_wholesale": "" }],
  "shared_grammar": [""],
  "differences": [{ "dimension": "", "positions": [""], "what_i_take": "" }],
  "visual_modes": [{ "key": "", "composition": "", "use_for": "", "avoid_for": "" }],
  "mode_selection_rules": [{ "spoken_beat": "", "default_mode": "" }],
  "pacing_targets": {
    "delivery_wpm_range": [0, 0], "hook_legible_by_sec": 0,
    "composition_change_sec": [0, 0], "micro_change_sec": [0, 0], "face_reset_rule": ""
  },
  "typography_hierarchy": [""],
  "motion_hierarchy": [""],
  "anti_patterns": [""],
  "synthesis": {
    "positioning_statement": "",
    "borrowed_from": [{ "creator": "", "what": "", "explicitly_not": "" }],
    "script_formula": [""]
  }
}
```

Required: `corpus_version`, `built_at`, `reels` (5 or more), `aggregate`
(with `total_runtime_sec` and `weighted_wpm`), `engines` (each with all four
fields), `shared_grammar` (3 or more), `visual_modes` (3 or more, each with all
four fields), and `synthesis` (with `positioning_statement` and a
`script_formula` of at least 3 steps).

## Before you start

Work straight through — do not ask me clarifying questions first. Everything you
need is in this message, and I may not be watching the screen while you work.

Begin by listing which URLs you were able to retrieve and which you could not,
so I can see the real coverage. Then do the analysis.

## One last thing about the JSON

Put the final JSON in a **single fenced code block**, complete and unabridged,
as the last thing in your reply. Do not split it across several blocks, do not
abbreviate any part of it with a comment such as `// ...same as above`, and do
not write anything after it. I copy that block directly into a file, so
anything missing from it is simply missing.
