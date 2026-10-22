#!/bin/bash
# Installs the scripts, the presets, and your editable folder template into ~/.project-folders
#   install.sh             -> installs with the default layout
#   install.sh podcast     -> installs and starts with the "podcast" layout
# Safe to re-run: it never overwrites a folders.txt you have already edited
# (unless you ask for a preset by name, in which case your old one is saved as folders.txt.bak).

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
DEST="$HOME/.project-folders"

mkdir -p "$DEST/presets"
cp "$HERE/create_project_folders.sh" "$DEST/create_project_folders.sh"
cp "$HERE/use-preset.sh" "$DEST/use-preset.sh"
chmod +x "$DEST/create_project_folders.sh" "$DEST/use-preset.sh"
cp "$REPO"/presets/*.txt "$DEST/presets/"

if [ "$#" -ge 1 ]; then
  "$DEST/use-preset.sh" "$1"
elif [ -f "$DEST/folders.txt" ]; then
  echo "Keeping your existing template: $DEST/folders.txt"
else
  cp "$REPO/presets/default.txt" "$DEST/folders.txt"
  echo "Installed default template: $DEST/folders.txt"
fi

# Remove the download quarantine flag if macOS added one
xattr -d com.apple.quarantine "$DEST/create_project_folders.sh" "$DEST/use-preset.sh" 2>/dev/null || true

cat <<EOF

Done. These now live in $DEST:
  folders.txt                 YOUR layout - edit this any time
  presets/                    ready-made layouts
  use-preset.sh               switch layouts:  use-preset.sh <name>
  create_project_folders.sh   the script (leave it alone)

Last step: add the right-click menu item. See "Mac setup, step 2" in the README.
Your Quick Action will run this one line:

  "\$HOME/.project-folders/create_project_folders.sh" "\$@"
EOF
