# How it works

## Shape

```
/corpus-build
      │
      ├─ asks for reel links in the conversation
      │        └──▶ corpus/reels.txt
      │
      ├─ tools/chatgpt_message.sh   prompt + links ──▶ clipboard
      │
      ├─ Chrome ──▶ chatgpt.com ──▶ paste, send
      │        ChatGPT retrieves and watches every reel
      │        └──▶ JSON block ──▶ corpus/corpus.json ──▶ corpus/corpus.md
      │
      └─ meanwhile: interviews the user ──▶ voice/voice.json
                                    │
                                    ▼
                          /reel-script <slug> <idea>
                                    │
                                    ▼
                 projects/<slug>/script.json + script.md
```

The `--local` lane replaces the middle section with `tools/corpus_fetch.sh`
(yt-dlp + ffmpeg → sampled frames) and the `corpus-analyst` agent reading those
frames directly. Same two output files.

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

**ChatGPT in Chrome (default).** The kit builds one long message — the analyst
prompt plus the user's links — puts it on the clipboard, opens a fresh tab,
pastes it, and polls for the result.

Clipboard rather than typing, for a specific reason: Enter sends the message in
ChatGPT, so typing a multi-line prompt keystroke-by-keystroke fires it off in
fragments. `pbcopy` + `cmd+V` gets it in as one message.

The result comes back through the code block's **copy button** into `pbpaste`,
rather than by scraping page text, because a long JSON block gets truncated when
scraped.

This lane exists because it is the one that actually reaches Instagram and
watches the videos. Its known weakness, checked for explicitly in step 7 of the
command: a model that cannot retrieve a video will sometimes write a plausible
entry for it anyway. Always compare the entry count against the URLs actually
retrieved.

**Local (`--local`).** `yt-dlp` + `ffmpeg`, everything on the user's machine,
nothing uploaded. Frames are sampled at one per second, capped at 45, scaled to
540px wide — legible enough to read burned-in captions while keeping the
analysis affordable. The numbers here are measured from real files rather than
estimated, so this lane is more accurate where it can reach the video at all.

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
