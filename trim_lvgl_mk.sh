#!/usr/bin/env bash
set -euo pipefail

mk_file="${1:-lvgl.mk}"

if [[ ! -f "$mk_file" ]]; then
  echo "error: $mk_file not found" >&2
  exit 1
fi

tmp="${mk_file}.tmp"

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" == *'$(LVGL_PATH)/demos '* ]]; then
    continue
  fi

  if [[ "$line" == *'$(LVGL_PATH)/examples '* ]]; then
    continue
  fi

  printf '%s\n' "$line"
done < "$mk_file" > "$tmp"

mv "$tmp" "$mk_file"
echo "trimmed $mk_file"
