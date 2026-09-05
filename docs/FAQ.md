# FAQ

### Do I need to install anything?

No. The default path drives ChatGPT in your Chrome — no installs, no API keys.
You need to be signed in to ChatGPT, ideally on a model that can browse.

`brew install yt-dlp ffmpeg` is optional and only enables `/corpus-build --local`.

### Why ChatGPT instead of doing it locally?

Because it is the path that reliably reaches Instagram and actually watches the
videos, rather than inferring structure from captions and thumbnails. The kit
drives it for you: you paste links, it does the rest.

The `--local` lane exists if you would rather keep everything on your machine.
Where it can reach a video at all its numbers are better, because they come from
measuring the real file instead of a model's estimate.

### ChatGPT could not fetch some of my reels.

Normal. Private accounts and deleted posts cannot be retrieved, and the analysis
runs on whatever came back.

If most failed, check you are signed in and on a browsing-capable model, then
run `/corpus-build` again. Do not build a corpus on four reels; the numbers will
not mean anything.

Watch for the opposite failure too: a model that could not fetch a video
sometimes writes a plausible entry for it anyway. `/corpus-build` checks the
entry count against what was actually retrieved, and it is worth a glance
yourself.

### Can I run the ChatGPT part myself?

Yes. `/corpus-build --manual` puts the prompt and your links on your clipboard.
Paste it into ChatGPT wherever you like, then bring the JSON block back with
`/corpus-import`.

### Is analyzing these reels okay?

You are studying publicly posted videos to learn how they were made — the same
thing you do when you rewatch something to work out how it was put together.

The kit keeps that boundary in two ways. On the `--local` lane, `corpus/raw/`
and `corpus/frames/` are gitignored, so footage is never committed or published
and stays on your disk. And the analysis records structure, pacing and technique
rather than reproducing anyone's script — quoting is limited to a short phrase,
and only where the exact wording is the thing being analyzed.

Your analysis is your own work. Their videos stay theirs.

### The analysis says something I disagree with.

Then it is wrong and you are right. Edit `corpus/corpus.md`.

The machine measured what it could see; you know why you saved those reels. Your
disagreement is the most valuable thing you can add, and a corpus you have
argued with is worth several times one you accepted unread.

### I have no results yet. Can I use this?

Yes, and it is worth being straight about it during the interview. Record claims
with `evidence_type: "none_yet"` and the agent treats them as hypotheses rather
than facts.

Your early scripts will lean on teaching and honest process instead of results.
That is a real position — often a more durable one than borrowed authority — and
the agent will not fabricate credentials to paper over it.

### The script has [NEEDS VERIFICATION] in it.

Working as intended. The agent could not trace that claim to an entry in your
proof list.

Either get the evidence and add it to `voice.json`, or cut the claim. Do not
publish past the flag — it is the one thing standing between you and saying
something on camera that you cannot back up.

### Can I use one creator instead of two or three?

You can, and the output will be noticeably worse.

With one creator there is no way to tell structure from personality — everything
they do looks essential. A second creator separates the two immediately: what
both do is grammar, what only one does is style.

### Why did it interview me in the middle of building the corpus?

Because ChatGPT is spending those minutes retrieving and watching your reels,
and that time is otherwise dead.

It also means there is no separate setup command: when `/corpus-build` finishes,
both files exist and you can go straight to `/reel-script`.

### How often should I rebuild the corpus?

When your taste moves. After twenty or thirty published videos it will have.

Run `/corpus-build` again with newer reels and bump `corpus_version`. Keep the
old `corpus.md` — the diff is one of the more interesting things this produces.

### Validation is failing and I do not understand the error.

The errors name the field and the problem, e.g.
`synthesis.script_formula: needs at least 3 item(s) (has 2)`.

Run `/reel-doctor` and it will interpret them. If a corpus is genuinely thin —
two visual modes where three are wanted — that is a real finding about the
analysis rather than a formatting issue. Do not pad it to pass; go and think
about the missing mode.

### Can I edit voice.json and corpus.json by hand?

Yes. Both are meant to be edited. Run `node tools/validate.mjs all` afterwards.

### Where are the other eight stages?

Coming. This is stage 1 of 9: script, research, beatmap, assets, storyboard,
ingest, composer, QC, revision.
