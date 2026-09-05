# Reel Script Kit

**Part 1 of 9 — the Script stage.**

An AI that writes short-form video scripts that sound like *you*, because it
learns from the reels *you* saved and the proof *you* can actually back up.

Not a prompt. Not a template pack. A small pipeline stage with a real contract:
it reads two files describing your taste, and refuses to run without them.

---

## The problem this solves

Ask any chatbot for a Reel script and you get the same script everyone else
gets. Confident, generic, structurally identical to a thousand others, full of
claims you cannot back up. It has no idea what good looks like *to you*, and no
idea what you have actually done.

Taste is not a prompt you can write. But it *is* sitting in your saved folder.

This kit turns that folder into something an agent can use:

```
reels you admire  ──▶  corpus.json   what good looks like, to you
who you are       ──▶  voice.json    what you can actually prove
                            │
                            ▼
                    /reel-script  ──▶  a script in your voice
```

## What makes it different

**It builds your corpus from real video.** It downloads the reels you list,
measures them — duration, hard cuts, pacing, words per minute — samples a frame
every second, and reads them. Not the captions. Not the thumbnails. The videos.

**It refuses to average your creators together.** If one of them changes the
whole screen every 2 seconds and another holds a composition for 5, that
difference is the most useful thing in the analysis. Most tools blend it into a
"house style" and destroy it. This one keeps them apart and makes you choose.

**It writes down what would go wrong if you copied someone.** Every creator's
engine gets a `risk_if_copied_wholesale` field. Copy the fast tool-demo format
and you become a faceless aggregator; copy the framework-teacher format before
you have results and you sound like a guru. Those sentences are the most useful
output in the whole document.

**It cannot make up your results.** `voice.json` holds a closed list of what you
can prove. Every factual claim in a script must trace to an entry, or it gets
flagged `[NEEDS VERIFICATION]` in the output. No invented statistics, no
placeholder numbers that look real.

**It knows what you have already said.** Repeat a hook you have published and
it treats that as a hard failure, not a style note.

**Zero dependencies.** The validator and doctor are plain Node. No `npm
install`, ever.

## Quick start

```bash
git clone <your-fork> reel-script-kit
cd reel-script-kit
claude
```

Then two commands. That is the whole kit.

```
/corpus-build                 paste your reel links
/reel-script <slug> <idea>    write the script
```

**`/corpus-build`** asks for your links in the conversation, then opens Chrome,
drives ChatGPT to actually retrieve and watch every reel, and brings the
analysis back. While that runs it interviews you about your own proof, so
nothing is left to set up afterwards.

**`/reel-script`** writes the script.

Nothing to install. No files to edit first. No API keys.

## Commands

| Command | |
|---|---|
| `/corpus-build` | **Setup.** Your links → ChatGPT watches them → `corpus.json` + `voice.json`. |
| `/reel-script` | Writes a script. Words only. |

Three more exist for when something goes sideways, and most people never need
them: `/reel-doctor` (health check), `/voice-setup` (redo the interview alone),
`/corpus-import` (bring in an analysis you ran in ChatGPT yourself).

### Why ChatGPT does the watching

It is the one path that reliably reaches Instagram and actually watches the
videos rather than guessing from captions and thumbnails. The kit drives it for
you — you paste links, it does the rest.

If you would rather keep everything on your own machine,
`brew install yt-dlp ffmpeg` and run `/corpus-build --local`: it downloads each
reel, measures duration and cuts with ffmpeg, and reads the frames directly.
Same output, nothing uploaded.

## What you end up with

```
voice/voice.json      who you are, what you can prove, how you may sound
corpus/corpus.json    your taste, measured and structured
corpus/corpus.md      the same thing, readable - go argue with it
projects/<slug>/
  script.json         validated, segmented by argument
  script.md           the version you actually perform
```

## Two things worth knowing

**Read `corpus.md` and edit it.** The machine measures; you judge. Where you
disagree with the analysis, that disagreement *is* your taste — write it in. A
corpus you have argued with is worth several times one you accepted.

**Downloaded reels never leave your machine.** `corpus/raw/` and
`corpus/frames/` are gitignored. Those are other people's copyrighted videos,
pulled locally so you can study them — the same way you would rewatch something
to learn from it. Your *analysis* is your own work and is what gets committed.
The kit analyzes structure and pacing; it does not reproduce anyone's script.

## Where this fits

This is stage 1 of a 9-stage pipeline. Each stage has narrow authority and is
not allowed to creatively reinterpret the video outside it. The script agent
controls **words only** — no visuals, no camera direction, no timing. That
constraint is the whole design: creative decisions happen early, on paper, while
they are still cheap to change, and execution happens late and stays boring.

The other eight stages — research, beatmap, assets, storyboard, ingest,
composer, QC, revision — follow.

## Docs

- [`QUICKSTART.md`](QUICKSTART.md) — start to first script
- [`docs/THE-METHOD.md`](docs/THE-METHOD.md) — how to choose reels, and why the method works
- [`docs/HOW-IT-WORKS.md`](docs/HOW-IT-WORKS.md) — architecture and the contracts
- [`docs/FAQ.md`](docs/FAQ.md) — troubleshooting

## License

MIT. See [LICENSE](LICENSE).
