#!/bin/bash
# Create Project Folders (macOS)
# Builds the folder layout listed in your folders.txt inside each folder you pass in.
#   - Empty folder     -> filled directly
#   - Non-empty folder -> a new "Untitled Project" folder is created inside it and filled
# Template lookup, first match wins:
#   $PROJECT_FOLDERS_TEMPLATE
#   ~/.project-folders/folders.txt
#   ~/.project-folders/presets/default.txt
#   presets/default.txt next to this repo

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE=""
for candidate in \
  "${PROJECT_FOLDERS_TEMPLATE:-}" \
  "$HOME/.project-folders/folders.txt" \
  "$HOME/.project-folders/presets/default.txt" \
  "$HERE/../presets/default.txt"; do
  if [ -n "$candidate" ] && [ -f "$candidate" ]; then
    TEMPLATE="$candidate"
    break
  fi
done
if [ -z "$TEMPLATE" ]; then
  echo "Could not find a folder template (folders.txt)." >&2
  exit 1
fi

# Names that break on Windows or other systems: < > : " | ? *  and names ending in . or space
BAD_CHARS='[<>:"|?*]'
BAD_END='[. ](/|$)'

is_empty_dir() {
  [ -z "$(ls -A "$1" | grep -v '^\.DS_Store$' | head -n 1 || true)" ]
}

unique_name() {
  local base="$1" candidate="$1" n=2
  while [ -e "$candidate" ]; do
    candidate="$base $n"
    n=$((n + 1))
  done
  printf '%s' "$candidate"
}

build_tree() {
  local dest="$1" line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    # trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    case "$line" in ''|'#'*) continue ;; esac
    # safety: no absolute paths, no parent-folder escapes
    case "$line" in
      /*|..|../*|*/..|*/../*)
        echo "Skipping unsafe line: $line" >&2
        continue ;;
    esac
    if [[ $line =~ $BAD_CHARS ]] || [[ $line =~ $BAD_END ]]; then
      echo "Skipping line with characters that break on other systems: $line" >&2
      continue
    fi
    mkdir -p "$dest/$line"
  done < "$TEMPLATE"
}

if [ "$#" -eq 0 ]; then
  echo "Usage: create_project_folders.sh <folder> [folder...]" >&2
  exit 1
fi

for target in "$@"; do
  [ -d "$target" ] || continue
  if is_empty_dir "$target"; then
    dest="$target"
  else
    dest="$(unique_name "$target/Untitled Project")"
    mkdir -p "$dest"
  fi
  build_tree "$dest"
  # Show the result in Finder when running on a Mac
  if command -v open >/dev/null 2>&1; then
    open -R "$dest" 2>/dev/null || true
  fi
done
