#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <path-without-.html-or-.md>" >&2
  exit 2
fi

base=$1
html="${base}.html"
md="${base}.md"

for file in "$html" "$md"; do
  if [ ! -f "$file" ]; then
    echo "missing: $file" >&2
    exit 1
  fi
done

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

rg -o 'data-ir-id="[^"]+"' "$html" \
  | sed 's/^.*data-ir-id="//; s/"$//' \
  | sort > "$tmp_dir/html-ids"

if [ ! -s "$tmp_dir/html-ids" ]; then
  echo "no data-ir-id found: $html" >&2
  exit 1
fi

duplicate_ids=$(uniq -d "$tmp_dir/html-ids" || true)
if [ -n "$duplicate_ids" ]; then
  echo "duplicate HTML IR IDs:" >&2
  echo "$duplicate_ids" >&2
  exit 1
fi

rg -o -P '\b(?:V|F|E|ST|MSG)(?:-[A-Z0-9]+)+\b(?!-\*)' "$md" \
  | sed 's/^.*://' \
  | sort -u > "$tmp_dir/md-all-ids" || true

rg -v '^(F-HIDDEN$|F-HIDDEN-|E-)' "$tmp_dir/md-all-ids" \
  > "$tmp_dir/md-required-html-ids" || true

comm -23 "$tmp_dir/md-required-html-ids" "$tmp_dir/html-ids" > "$tmp_dir/md-only"
comm -13 "$tmp_dir/md-all-ids" "$tmp_dir/html-ids" > "$tmp_dir/html-only"

if [ -s "$tmp_dir/md-only" ]; then
  echo "Markdown visual IDs missing from HTML:" >&2
  sed -n '1,80p' "$tmp_dir/md-only" >&2
  exit 1
fi

if [ -s "$tmp_dir/html-only" ]; then
  echo "HTML IR IDs missing from Markdown:" >&2
  sed -n '1,80p' "$tmp_dir/html-only" >&2
  exit 1
fi

awk '
  /^## 9\./ { in_events=1; next }
  /^## / && in_events { exit }
  in_events { print }
' "$md" \
  | sed -nE 's/^\|[[:space:]]*`?(E-[A-Z0-9-]+)`?[[:space:]]*\|.*/\1/p' \
  | sort > "$tmp_dir/event-definition-ids"

duplicate_events=$(uniq -d "$tmp_dir/event-definition-ids" || true)
if [ -n "$duplicate_events" ]; then
  echo "duplicate Markdown event definition IDs:" >&2
  echo "$duplicate_events" >&2
  exit 1
fi

{
  rg -o -P '\bU(?:-[A-Z0-9]+)+\b(?!-\*)' "$md" || true
  rg -o 'data-unknown-ref="[^"]+"' "$html" \
    | sed 's/^.*data-unknown-ref="//; s/"$//' || true
} | sort -u > "$tmp_dir/unknown-reference-ids"

awk '
  /^## 13\./ { in_unknowns=1; next }
  /^## / && in_unknowns { exit }
  in_unknowns { print }
' "$md" \
  | sed -nE 's/^\|[[:space:]]*`?(U-[A-Z0-9-]+)`?[[:space:]]*\|.*/\1/p' \
  | sort -u > "$tmp_dir/unknown-definition-ids"

comm -23 "$tmp_dir/unknown-reference-ids" "$tmp_dir/unknown-definition-ids" \
  > "$tmp_dir/unknown-unresolved"
if [ -s "$tmp_dir/unknown-unresolved" ]; then
  echo "unknown IDs referenced but not defined in Markdown section 13:" >&2
  sed -n '1,80p' "$tmp_dir/unknown-unresolved" >&2
  exit 1
fi

if rg -n '<script\b|<%|\$\{|Ajax\.Request|fetch\(|XMLHttpRequest|\.submit\(|https?://' "$html"; then
  echo "HTML contains forbidden executable/source syntax or network reference" >&2
  exit 1
fi

screen_id=$(basename "$base")
if ! rg -q "data-screen-id=\"${screen_id}\"" "$html"; then
  echo "HTML screen id does not match basename: $screen_id" >&2
  exit 1
fi
if ! rg -q "screen_id:[[:space:]]*\"?${screen_id}\"?" "$md"; then
  echo "Markdown screen id does not match basename: $screen_id" >&2
  exit 1
fi

for section in $(seq 0 18); do
  if ! rg -q "^## ${section}\." "$md"; then
    echo "missing Markdown section: $section" >&2
    exit 1
  fi
done

printf 'ok\t%s\thtml_ids=%s\tmd_visual_ids=%s\n' \
  "$screen_id" \
  "$(wc -l < "$tmp_dir/html-ids" | tr -d ' ')" \
  "$(wc -l < "$tmp_dir/md-all-ids" | tr -d ' ')"
