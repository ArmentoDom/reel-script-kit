# How it works

## Shape

```
corpus/reels.txt          you list the reels you admire
      │
      ▼  tools/corpus_fetch.sh        yt-dlp + ffmpeg
corpus/raw/<creator>/<id>.mp4         (gitignored)
corpus/frames/<id>/                   (gitignored)
   f0001.jpg ... one per second
   audio.m4a
   meta.json  ← measured: duration, cuts, avg scene length
      │
      ▼  agent: corpus-analyst        reads every frame
corpus/corpus.json  +  corpus/corpus.md
      │
      │        voice/voice.json  ← agent-free: /voice-setup interviews you
      │              │
      ▼              ▼
         agent: reel-script
              │
              ▼
   projects/<slug>/script.json + script.md
```

## The two inputs, and why they are separate

| | `corpus.json` | `voice.json` |
|---|---|---|
| Describes | other people's videos | you |
| Answers | what does good look like | what am I allowed to say |
| Built by | measurement + analysis | an interview |
| Changes when | your taste moves | you ship something new |

Keeping them apart is a deliberate design decision. Merged, an analysis of
creators you admire drifts into becoming claims about yourself. Separate, the
proof list stays a hard boundary the script agent cannot cross.

## Narrow authority

Every stage decides one thing and is forbidden from the rest.

The script agent controls **words only**. Not visuals, not camera direction, not
graphics, not timing. If it starts writing "then show a diagram of…" it has
exceeded its authority, and its own instructions tell it to stop.

This looks like bureaucracy and is the opposite. The failure mode it prevents is
specific and expensive: creative decisions leaking into the execution stage,
where changing them costs a re-render instead of a sentence. Decide early, on
paper, while it is cheap. Execute late, and keep execution boring.

## Why validation is hand-rolled

`tools/validate.mjs` implements the JSON Schema subset the kit actually uses —
`type`, `required`, `properties`, `items`, `enum`, `minLength`, `minItems`,
`minimum`, `maximum`. About 120 lines of plain Node.

The alternative is a dependency, a lockfile, an install step, and a way for
someone to fail before they have written anything. For nine keywords, not worth
it. Clone and run.

## The two lanes

**Local** (`yt-dlp` + `ffmpeg` present) — downloads and measures on your
machine. Numbers come from the real files. Nothing is uploaded. Frames are
sampled at one per second, capped at 45, scaled to 540px wide, which is legible
enough to read burned-in captions while keeping the analysis affordable.

**Browser** (`--browser`) — hands a structured prompt to ChatGPT, which
retrieves and analyzes the videos. No installs. Also the fallback for
login-gated reels the local lane cannot reach.

The known weakness of the browser lane, and the reason `/corpus-import` checks
for it explicitly: a model that cannot retrieve a video may write a plausible
entry for it anyway. The import step compares the entry count against the URLs
you actually supplied.

## Scene detection

```bash
ffmpeg -v error -i in.mp4 \
  -filter:v "select='gt(scene,0.3)',metadata=print:file=-" \
  -an -f null - | grep -c pts_time
```

`metadata=print` rather than `showinfo` — `showinfo` writes at loglevel `info`
and is silently swallowed by `-v error`, which makes every reel report a single
scene. That is a quiet failure that produces confident wrong numbers, so it is
worth knowing about if you modify the script.

The count catches hard cuts and large compositional changes. It misses caption
swaps, progressive reveals and micro-motion, so treat it as a floor rather than
a total. The corpus says so in writing for the same reason.

## Extending it

**More stages.** Each is an agent in `.claude/agents/` with a matching command
in `.claude/commands/`, a schema in `schemas/`, and one job. The next stage
reads this stage's JSON.

**A different validator field.** Add the keyword to the `validate` function in
`tools/validate.mjs` — it is a single recursive function, deliberately readable.

**A different frame rate.** `tools/corpus_fetch.sh --fps 0.5` samples every half
second; `--max-frames` raises the cap. Denser sampling reads fast-cut reels more
accurately and costs more to analyze.
