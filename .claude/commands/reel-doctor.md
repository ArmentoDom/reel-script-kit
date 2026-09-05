---
description: "Check that everything is set up correctly and tell me what to do next"
argument-hint: "(no arguments)"
---

# Doctor

Run:

```bash
node tools/doctor.mjs
node tools/validate.mjs all
```

Show the output, then interpret it in a sentence or two — the point is to tell
them the single next thing to do, not to make them read a status table.

If something is broken, fix what is safely fixable (a malformed JSON field, a
missing directory) and explain anything that needs their judgment.

Common situations:

| What you see | What to say |
|---|---|
| Nothing set up yet | Run `/corpus-build` — it collects the links, drives ChatGPT, and interviews them. |
| No `corpus.json` | Run `/corpus-build`. |
| `corpus.json` but no `voice.json` | Setup was interrupted. Run the `/voice-setup` interview to finish it. |
| `reels.txt` empty | `/corpus-build` asks for the URLs directly; no need to edit the file first. |
| Local tools missing | Irrelevant by default — the ChatGPT lane needs no installs. Only matters for `/corpus-build --local`. |
| Validation failures | Show the exact errors — they name the field and the problem. |
| Everything green | Tell them to write something: `/reel-script <slug> <idea>`. |
