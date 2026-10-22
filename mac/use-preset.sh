#!/bin/bash
# Switch your folder layout to a preset.
#   use-preset.sh            -> lists the presets
#   use-preset.sh podcast    -> makes "podcast" your active layout
# Your previous folders.txt is saved as folders.txt.bak first.

set -euo pipefail

DEST="$HOME/.project-folders"
HERE="$(cd "$(dirname "$0")" && pwd)"

PRESETS="$DEST/presets"
[ -d "$PRESETS" ] || PRESETS="$HERE/../presets"

if [ "$#" -eq 0 ]; then
  echo "Available presets:"
  for f in "$PRESETS"/*.txt; do
    echo "  $(basename "$f" .txt)"
  done
  echo
  echo "Switch with:  use-preset.sh <name>"
  exit 0
fi

NAME="$1"
if [[ ! $NAME =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "Preset names use only letters, numbers, dashes and underscores." >&2
  exit 1
fi
SRC="$PRESETS/$NAME.txt"
if [ ! -f "$SRC" ]; then
  echo "No preset called '$NAME'. Run without a name to see the list." >&2
  exit 1
fi

mkdir -p "$DEST"
if [ -f "$DEST/folders.txt" ] && ! cmp -s "$SRC" "$DEST/folders.txt"; then
  cp "$DEST/folders.txt" "$DEST/folders.txt.bak"
  echo "Saved your previous layout as folders.txt.bak"
fi
cp "$SRC" "$DEST/folders.txt"
echo "Layout is now: $NAME"
