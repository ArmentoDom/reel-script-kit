# corpus/

Your taste, made machine-readable.

| Path | What it is | Committed? |
|---|---|---|
| `reels.txt` | The reel URLs you admire, grouped by creator. **You edit this.** | yes |
| `raw/` | Downloaded videos | **no** — gitignored |
| `frames/` | Sampled frames, audio and per-reel `meta.json` | **no** — gitignored |
| `corpus.json` | The structured analysis the script agent reads | yes |
| `corpus.md` | The same analysis, readable, for you | yes |
| `TEMPLATE_corpus.md` | Blank scaffold showing every section a corpus needs | yes |
| `example/` | A small **fictional** worked example | yes |
| `prompts/` | The ChatGPT prompt for the browser lane | yes |

## Why raw video is never committed

`raw/` and `frames/` hold other people's copyrighted videos. Downloading them
to study privately is one thing; republishing them in a git repo — even a
private one — is another. `.gitignore` blocks them, and you should leave that
alone.

Your **analysis** is a different matter entirely. It is your own commentary and
measurement, it contains no one else's footage, and it is the actual asset. That
is what gets committed.

## Rebuilding

A corpus is a snapshot of your taste on the day you built it. When your taste
moves — and after 20 or 30 published videos it will — add newer reels to
`reels.txt` and run `/corpus-build` again. Bump `corpus_version`. Keep the old
`corpus.md` around; the diff between v1 and v2 is one of the more interesting
things this kit produces.
