# FAQ

### Most of my reels failed to download.

Private accounts, deleted posts, and login-gated content cannot be fetched.
Normal, and not a problem if it is a few — analysis runs on whatever came down.

If most of them failed, use `/corpus-build --browser`, which goes through
ChatGPT and can reach more. Do not build a corpus on four reels; the numbers
will not mean anything.

### Do I have to install yt-dlp and ffmpeg?

No. `/corpus-build --browser` needs nothing installed.

They are worth installing, though: the local lane measures the real video files
rather than relying on a model's estimate, and nothing leaves your machine.

```bash
brew install yt-dlp ffmpeg
```

### Is downloading these reels okay?

You are fetching publicly posted videos to study privately — the same thing you
do when you rewatch something to work out how it was made.

The kit takes this seriously in two ways: `corpus/raw/` and `corpus/frames/` are
gitignored so footage is never committed or published, and the analysis records
structure, pacing and technique rather than reproducing anyone's script. Your
analysis is your own work. Their video stays theirs, and stays on your disk.

### The analysis says something I disagree with.

Then it is wrong and you are right. Edit `corpus/corpus.md`.

The machine measured what it could see; you know why you saved those reels.
Your disagreement is the most valuable thing you can add, and a corpus you have
argued with is worth several times one you accepted unread.

### I have no results yet. Can I use this?

Yes, and it is worth being straight in `/voice-setup` about it. Record claims
with `evidence_type: "none_yet"` and the agent treats them as hypotheses rather
than facts.

Your early scripts will lean on teaching and honest process instead of results.
That is a real position — often a more durable one than borrowed authority —
and the agent will not fabricate credentials to paper over it.

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

### How often should I rebuild the corpus?

When your taste moves. After twenty or thirty published videos it will have.

Add newer reels to `corpus/reels.txt`, run `/corpus-build` again, and bump
`corpus_version`. Keep the old `corpus.md` — the diff is one of the more
interesting things this produces.

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
