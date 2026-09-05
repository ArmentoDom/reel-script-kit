# voice/

Who you are, what you can prove, and how you are allowed to sound.

| File | |
|---|---|
| `voice.json` | Yours. Created by `/voice-setup`. |
| `voice.example.json` | A fictional example, to show the shape. |

## Why this file exists separately from the corpus

The corpus describes *other people's* work — what good looks like. This file
describes *you*. Keeping them apart matters: it is what stops an analysis of
creators you admire from quietly turning into a set of claims about yourself.

## The proof list is a closed set

`proof[]` is the important part. The script agent may only make factual claims
that trace back to an entry in it. Anything else gets flagged
`[NEEDS VERIFICATION]` in the output rather than written as fact.

That means:

- **Be strict about `verified`.** It should mean *you personally checked this is
  accurate and current*, not *this sounds about right*.
- **Use `expires`.** Rankings, revenue and follower counts go stale. A date
  makes the agent flag them for rechecking instead of repeating them forever.
- **`none_yet` is a valid answer.** If you have not built the proof yet, record
  the claim with `evidence_type: "none_yet"` and `verified: false`. The agent
  will treat it as a hypothesis rather than a fact.

The cost of a missing entry is one follow-up question. The cost of an inflated
one is a false claim in a published video.

## banned_claims

Things that are true but you have decided not to say — income, employer,
clients, NDA, or simply taste. The agent never argues with this list.

## used_hooks / used_ctas

Grows as you publish. A repeated hook is treated as a hard failure, which is
the correct severity: reusing your own opening is how an account starts feeling
same-y long before the creator notices.
