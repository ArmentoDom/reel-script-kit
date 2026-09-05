#!/usr/bin/env bash
# Download every reel listed in corpus/reels.txt, then prepare it for analysis:
# duration, hard-cut count, sampled frames, and an audio track.
#
# Reads : corpus/reels.txt
# Writes: corpus/raw/<creator>/<id>.mp4
#         corpus/frames/<id>/f####.jpg  + audio.m4a + meta.json
#
# usage: tools/corpus_fetch.sh [--fps <n>] [--max-frames <n>] [--force]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$ROOT/corpus/reels.txt"
RAW="$ROOT/corpus/raw"
FRAMES="$ROOT/corpus/frames"

SAMPLE_EVERY=1.0   # seconds between sampled frames
MAX_FRAMES=45      # hard cap per reel, keeps analysis affordable
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fps)         SAMPLE_EVERY="$2"; shift 2 ;;
    --max-frames)  MAX_FRAMES="$2";   shift 2 ;;
    --force)       FORCE=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

for bin in yt-dlp ffmpeg ffprobe; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: '$bin' is not installed. Run: node tools/doctor.mjs" >&2; exit 1; }
done
[[ -f "$LIST" ]] || { echo "error: $LIST not found. Add your reel URLs there first." >&2; exit 1; }

creator="unsorted"
ok=0; failed=0; skipped=0
declare -a FAILED_URLS=()

# `|| [[ -n $line ]]` so a final line without a trailing newline is still read
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%$'\r'}"                      # tolerate CRLF from a pasted file
  trimmed="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  [[ -z "$trimmed" ]] && continue

  # "# creator: Name" starts a new group; any other comment is ignored
  if [[ "$trimmed" == \#* ]]; then
    if [[ "$trimmed" =~ ^#[[:space:]]*creator:[[:space:]]*(.+)$ ]]; then
      creator="$(echo "${BASH_REMATCH[1]}" | tr ' ' '-' | tr -cd '[:alnum:]-_' | tr '[:upper:]' '[:lower:]')"
      [[ -z "$creator" ]] && creator="unsorted"
      echo ""
      echo "=== creator: $creator ==="
    fi
    continue
  fi

  [[ "$trimmed" =~ ^https?:// ]] || { echo "  skip (not a URL): $trimmed"; continue; }

  # Stable id from the URL's last meaningful path segment
  id="$(echo "$trimmed" | sed 's#/*$##' | awk -F/ '{print $NF}' | cut -d'?' -f1 | tr -cd '[:alnum:]_-')"
  [[ -z "$id" ]] && id="reel_$(echo "$trimmed" | cksum | cut -d' ' -f1)"

  outdir="$RAW/$creator"
  mkdir -p "$outdir"
  video="$outdir/$id.mp4"

  if [[ -f "$video" && $FORCE -eq 0 ]]; then
    echo "  have  $creator/$id.mp4"
    skipped=$((skipped+1))
  else
    echo "  get   $creator/$id ..."
    if ! yt-dlp -q --no-warnings \
         -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/b' \
         --merge-output-format mp4 \
         -o "$video" "$trimmed" 2>/dev/null; then
      echo "  FAIL  $id  (private, removed, or login-gated)"
      FAILED_URLS+=("$trimmed")
      failed=$((failed+1))
      continue
    fi
  fi

  [[ -f "$video" ]] || { failed=$((failed+1)); FAILED_URLS+=("$trimmed"); continue; }

  # ---- prepare for analysis ----
  fdir="$FRAMES/$id"
  mkdir -p "$fdir"

  dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video" 2>/dev/null | cut -d. -f1)"
  [[ -z "$dur" || "$dur" == "N/A" ]] && dur=0

  dims="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$video" 2>/dev/null || echo "?")"

  # Hard cuts / large compositional changes. A floor, not a true total:
  # it misses caption swaps, progressive reveals and micro-motion.
  # metadata=print (not showinfo) - showinfo writes at loglevel info and is
  # swallowed by -v error, which silently reports every reel as having 1 scene.
  cuts="$(ffmpeg -nostdin -v error -i "$video" \
            -filter:v "select='gt(scene,0.3)',metadata=print:file=-" \
            -an -f null - 2>/dev/null | grep -c 'pts_time' || true)"
  cuts=$((cuts + 1))   # N detected changes means N+1 held compositions

  if [[ $FORCE -eq 1 || ! -f "$fdir/f0001.jpg" ]]; then
    rm -f "$fdir"/f*.jpg
    ffmpeg -nostdin -v error -i "$video" \
      -vf "fps=1/$SAMPLE_EVERY,scale=540:-2" \
      -frames:v "$MAX_FRAMES" -q:v 4 "$fdir/f%04d.jpg" 2>/dev/null || true
  fi

  if [[ $FORCE -eq 1 || ! -f "$fdir/audio.m4a" ]]; then
    ffmpeg -nostdin -v error -y -i "$video" -vn -c:a aac -b:a 96k "$fdir/audio.m4a" 2>/dev/null || true
  fi

  nframes="$(find "$fdir" -name 'f*.jpg' | wc -l | tr -d ' ')"
  avg_scene="$(awk -v d="$dur" -v c="$cuts" 'BEGIN{ if (c>0) printf "%.2f", d/c; else print 0 }')"

  cat > "$fdir/meta.json" <<JSON
{
  "id": "$id",
  "creator": "$creator",
  "url": "$trimmed",
  "local_file": "corpus/raw/$creator/$id.mp4",
  "duration_sec": $dur,
  "dimensions": "$dims",
  "scene_count": $cuts,
  "avg_scene_sec": $avg_scene,
  "frames_dir": "corpus/frames/$id",
  "frame_count": $nframes,
  "seconds_per_frame": $SAMPLE_EVERY
}
JSON

  echo "        ${dur}s · ${cuts} cuts · ${avg_scene}s/scene · ${nframes} frames"
  ok=$((ok+1))
done < "$LIST"

echo ""
echo "-----------------------------------------"
echo "ready: $ok    already had: $skipped    failed: $failed"
if [[ ${#FAILED_URLS[@]} -gt 0 ]]; then
  echo ""
  echo "These could not be downloaded (usually private, deleted, or login-gated):"
  for u in "${FAILED_URLS[@]}"; do echo "  $u"; done
  echo ""
  echo "Nothing is broken - analysis will just run on the reels that did download."
fi
echo ""
