#!/usr/bin/env bash
set -euo pipefail

# Trim the current LVGL checkout in place.
#
# Default mode is dry-run and only prints what would be removed.
# Run with --apply to actually delete files/directories.
#
# Kept paths:
#   src/
#   include/
#   examples/porting/
#   lvgl.h
#   lv_conf_template.h
#   lv_version.h
#   lvgl_private.h
#   lvgl.mk
#   README.md
#   LICENCE.txt
#   COPYRIGHTS.md
#   create_trimmed_branch.sh
#
# Usage:
#   ./create_trimmed_branch.sh          # dry-run
#   ./create_trimmed_branch.sh --apply  # delete unneeded files

APPLY=0
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=1
elif [[ $# -gt 0 ]]; then
  echo "usage: $0 [--apply]" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

remove_path() {
  local path="$1"
  if [[ "$APPLY" -eq 1 ]]; then
    rm -rf -- "$path"
  else
    printf 'would remove: %s\n' "$path"
  fi
}

# Remove all top-level entries except the minimal LVGL library files and
# metadata needed by the trimmed package.
while IFS= read -r -d '' entry; do
  name="${entry#./}"
  case "$name" in
    .git|src|include|examples|lvgl.h|lv_conf_template.h|lv_version.h|lvgl_private.h|README.md|LICENCE.txt|COPYRIGHTS.md|lvgl.mk|create_trimmed_branch.sh)
      ;;
    *)
      remove_path "$entry"
      ;;
  esac
done < <(find . -mindepth 1 -maxdepth 1 -print0)

# Keep only examples/porting under examples/.
if [[ -d examples ]]; then
  while IFS= read -r -d '' entry; do
    name="${entry#examples/}"
    case "$name" in
      porting)
        ;;
      *)
        remove_path "$entry"
        ;;
    esac
  done < <(find examples -mindepth 1 -maxdepth 1 -print0)
fi

if [[ "$APPLY" -eq 1 ]]; then
  cat > TRIMMED_README.md <<'TRIMMED_README_EOF'
# Trimmed LVGL

This checkout was trimmed for embedded STM32 projects.
It keeps only the LVGL library sources, public headers, porting examples,
and license/readme metadata.

Kept paths:

- `src/`
- `include/`
- `examples/porting/`
- `lvgl.h`
- `lv_conf_template.h`
- `lv_version.h`
- `lvgl_private.h`
- `lvgl.mk`
- `README.md`
- `LICENCE.txt`
- `COPYRIGHTS.md`
- `create_trimmed_branch.sh`
TRIMMED_README_EOF
  echo "trimmed LVGL checkout in: $repo_root"
else
  echo "dry-run only; rerun with --apply to delete these paths"
fi
