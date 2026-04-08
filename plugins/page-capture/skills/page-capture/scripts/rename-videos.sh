#!/bin/bash
# rename-videos.sh — Rename Playwright video files from hashes to descriptive names
#
# Usage:
#   ./rename-videos.sh <directory> <name1> [name2] [name3] ...
#
# Renames webm files in order of creation time to the given names.
# Example:
#   ./rename-videos.sh ./screenshots "01-overview" "02-interaction" "03-demo"

DIR="$1"
shift

if [ -z "$DIR" ] || [ $# -eq 0 ]; then
  echo "Usage: $0 <directory> <name1> [name2] ..."
  echo "  Renames page@*.webm files in creation order to given names."
  exit 1
fi

# Get webm files sorted by modification time (oldest first)
FILES=($(ls -1t "$DIR"/page@*.webm 2>/dev/null | tac))

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No page@*.webm files found in $DIR"
  exit 1
fi

i=0
for name in "$@"; do
  if [ $i -ge ${#FILES[@]} ]; then
    echo "Warning: more names than files, skipping '$name'"
    break
  fi
  src="${FILES[$i]}"
  dst="$DIR/${name}.webm"
  echo "  $src → $dst"
  mv "$src" "$dst"
  ((i++))
done

remaining=$((${#FILES[@]} - i))
if [ $remaining -gt 0 ]; then
  echo "Warning: $remaining webm files were not renamed"
fi
