#!/bin/bash
# make_sleepcast_week.sh
# 一週間分(7日)の入眠音声をmp3に結合して生成する

set -e

OUTDIR="$HOME/sleepcast_week"
TMPDIR=$(mktemp -d)
mkdir -p "$OUTDIR"

trap "rm -rf $TMPDIR" EXIT

# omkr-radio RSSから全URLを取得してシャッフル
echo "Fetching omkr-radio RSS..."
OMKR_URLS=$(curl -s https://arrow2nd.github.io/omkr-radio/podcast/watch.rss \
  | grep enclosure \
  | awk -F'"' '{print $2}' \
  | shuf)

# bamf-radio RSSから全URLを取得
echo "Fetching bamf-radio RSS..."
BAMF_URLS=$(curl -s https://media.rss.com/bamf-radio/feed.xml \
  | grep -oP '(?<=<enclosure url=")[^"]+' \
  | shuf)

OMKR_ARRAY=($OMKR_URLS)
BAMF_ARRAY=($BAMF_URLS)

for DAY in $(seq 1 7); do
  echo "=== Day $DAY ==="
  DAYDIR="$TMPDIR/day$DAY"
  mkdir -p "$DAYDIR"

  # omkr-radio: 1エピソード (~30分)
  OMKR_URL="${OMKR_ARRAY[$((DAY-1))]}"
  echo "  Downloading omkr: $OMKR_URL"
  curl -sL "$OMKR_URL" -o "$DAYDIR/omkr.mp3"

  # bamf-radio: 3本ダウンロードして30分でカット
  BAMF_CONCAT_LIST="$DAYDIR/bamf_list.txt"
  > "$BAMF_CONCAT_LIST"
  for j in $(seq 0 2); do
    IDX=$(( (DAY-1)*5 + j ))
    BAMF_URL="${BAMF_ARRAY[$IDX]}"
    if [ -z "$BAMF_URL" ]; then continue; fi
    echo "  Downloading bamf[$j]: $BAMF_URL"
    curl -sL "$BAMF_URL" -o "$DAYDIR/bamf_${j}.mp3"
    echo "file '$DAYDIR/bamf_${j}.mp3'" >> "$BAMF_CONCAT_LIST"
  done

  # bamf分を結合して30分でカット
  ffmpeg -y -f concat -safe 0 -i "$BAMF_CONCAT_LIST" \
    -t 1800 -acodec copy "$DAYDIR/bamf_combined.mp3" -loglevel error

  # omkr + bamf を結合 (合計約60分)
  echo "file '$DAYDIR/omkr.mp3'"           >  "$DAYDIR/final_list.txt"
  echo "file '$DAYDIR/bamf_combined.mp3'"  >> "$DAYDIR/final_list.txt"

  OUTFILE="$OUTDIR/sleepcast_day${DAY}.mp3"
  ffmpeg -y -f concat -safe 0 -i "$DAYDIR/final_list.txt" \
    -acodec copy "$OUTFILE" -loglevel error

  echo "  -> $OUTFILE"
done

echo ""
echo "Done! Files are in $OUTDIR/"
ls -lh "$OUTDIR/"
