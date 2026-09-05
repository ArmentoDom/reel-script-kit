#!/usr/bin/env bash
# Build the single kickoff message for the ChatGPT lane: the analyst prompt
# with the user's reel list appended, copied to the clipboard.
#
# Typing this into ChatGPT keystroke-by-keystroke does not work - Enter sends
# the message, so a multi-line prompt fires off in fragments. Clipboard paste
# (cmd+V) is the only reliable way to get it in as one message.
#
# usage: tools/chatgpt_message.sh
# writes: .chatgpt_message.txt  (gitignored) and copies it to the clipboard

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT="$ROOT/corpus/prompts/chatgpt-corpus-analyst.md"
LIST="$ROOT/corpus/reels.txt"
OUT="$ROOT/.chatgpt_message.txt"

[[ -f "$PROMPT" ]] || { echo "error: missing $PROMPT" >&2; exit 1; }
[[ -f "$LIST" ]]   || { echo "error: missing $LIST" >&2; exit 1; }

# Count real URLs (ignore comments and blanks)
urls=$(grep -cE '^[[:space:]]*https?://' "$LIST" || true)
if [[ "$urls" -eq 0 ]]; then
  echo "error: no URLs in corpus/reels.txt yet." >&2
  exit 1
fi

{
  cat "$PROMPT"
  echo ""
  echo "---"
  echo ""
  echo "# MY REELS"
  echo ""
  echo "Grouped by creator. Analyze every one you can retrieve."
  echo ""
  # Pass through creator headers and URLs; drop instructional comments
  # A creator header is only emitted once a URL actually appears under it,
  # so the placeholder groups in the shipped template never leak through.
  pending=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%$'\r'}"
    t="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [[ "$t" =~ ^#[[:space:]]*creator:[[:space:]]*(.+)$ ]]; then
      pending="${BASH_REMATCH[1]}"
    elif [[ "$t" =~ ^https?:// ]]; then
      if [[ -n "$pending" ]]; then
        echo ""
        echo "## $pending"
        pending=""
      fi
      echo "- $t"
    fi
  done < "$LIST"
} > "$OUT"

if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$OUT"
  copied="yes"
elif command -v xclip >/dev/null 2>&1; then
  xclip -selection clipboard < "$OUT"
  copied="yes"
else
  copied="no"
fi

chars=$(wc -c < "$OUT" | tr -d ' ')
echo "built  $OUT"
echo "urls   $urls"
echo "size   $chars chars"
if [[ "$copied" == "yes" ]]; then
  echo "clip   copied to clipboard - paste into ChatGPT with cmd+V"
else
  echo "clip   NO CLIPBOARD TOOL - paste the file contents manually"
fi
