#!/bin/bash
# Checks every preset and the Mac scripts. Run from anywhere:  bash tests/run.sh
# Used by the GitHub Action, and handy before you submit a new preset.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
failures=0

fail() { echo "  FAIL: $1"; failures=$((failures + 1)); }
pass() { echo "  ok:   $1"; }

BAD_CHARS='[<>:"|?*]'
BAD_END='[. ](/|$)'

echo "Checking presets"
for f in "$ROOT"/presets/*.txt; do
  name="$(basename "$f")"
  cleaned="$TMP/clean-$name"
  : > "$cleaned"
  problems=0
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    case "$line" in ''|'#'*) continue ;; esac
    case "$line" in
      /*|..|../*|*/..|*/../*) fail "$name: unsafe path '$line'"; problems=1; continue ;;
    esac
    if [[ $line =~ $BAD_CHARS ]] || [[ $line =~ $BAD_END ]]; then
      fail "$name: name breaks on other systems '$line'"; problems=1; continue
    fi
    echo "$line" >> "$cleaned"
  done < "$f"

  if [ ! -s "$cleaned" ]; then fail "$name: no folders listed"; problems=1; fi
  dupes="$(sort "$cleaned" | uniq -d)"
  if [ -n "$dupes" ]; then fail "$name: duplicate lines: $dupes"; problems=1; fi
  [ "$problems" -eq 0 ] && pass "$name"
done

echo "Building every preset with the Mac script"
for f in "$ROOT"/presets/*.txt; do
  name="$(basename "$f" .txt)"
  out="$TMP/out-$name"
  mkdir -p "$out"
  warn="$(HOME="$TMP/home" PROJECT_FOLDERS_TEMPLATE="$f" bash "$ROOT/mac/create_project_folders.sh" "$out" 2>&1 >/dev/null)"
  count="$(find "$out" -type d | wc -l | tr -d ' ')"
  if [ -n "$warn" ]; then fail "$name: script warned: $warn"
  elif [ "$count" -lt 2 ]; then fail "$name: no folders created"
  else pass "$name ($((count - 1)) folders)"; fi
done

echo "Checking empty vs non-empty folder behavior"
mkdir -p "$TMP/behave/full"
echo x > "$TMP/behave/full/file.txt"
HOME="$TMP/home" PROJECT_FOLDERS_TEMPLATE="$ROOT/presets/minimal.txt" \
  bash "$ROOT/mac/create_project_folders.sh" "$TMP/behave/full"
[ -d "$TMP/behave/full/Untitled Project/MEDIA" ] && pass "non-empty folder gets 'Untitled Project'" \
  || fail "non-empty folder did not get 'Untitled Project'"
[ -f "$TMP/behave/full/file.txt" ] && pass "existing files untouched" || fail "existing file was changed"

echo "Checking install and preset switching"
export HOME="$TMP/inst"
mkdir -p "$HOME"
bash "$ROOT/mac/install.sh" >/dev/null
cmp -s "$ROOT/presets/default.txt" "$HOME/.project-folders/folders.txt" \
  && pass "install uses default layout" || fail "install did not use default layout"
"$HOME/.project-folders/use-preset.sh" podcast >/dev/null
cmp -s "$ROOT/presets/podcast.txt" "$HOME/.project-folders/folders.txt" \
  && pass "use-preset switches layout" || fail "use-preset did not switch layout"
[ -f "$HOME/.project-folders/folders.txt.bak" ] && pass "previous layout backed up" || fail "no backup made"
"$HOME/.project-folders/use-preset.sh" "../evil" >/dev/null 2>&1 \
  && fail "bad preset name was accepted" || pass "bad preset name rejected"
echo "# my edit" >> "$HOME/.project-folders/folders.txt"
bash "$ROOT/mac/install.sh" >/dev/null
grep -q "# my edit" "$HOME/.project-folders/folders.txt" \
  && pass "re-install keeps user edits" || fail "re-install overwrote user edits"

echo
if [ "$failures" -eq 0 ]; then echo "All checks passed."; exit 0; fi
echo "$failures check(s) failed."
exit 1
