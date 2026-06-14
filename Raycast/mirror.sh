#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Mirror Drives
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🪩
# @raycast.needsConfirmation true

export LC_ALL=C

SOURCES=(
  "Date16" 
  "Data8" 
  "Untitled"
)

BACKUP_ROOT="/Volumes/Data8 32GB"

for DRIVE in "${SOURCES[@]}"; do
  SRC="/Volumes/$DRIVE"
  DST="$BACKUP_ROOT/$DRIVE"

  # Skip if source drive is not mounted
  if [[ ! -d "$SRC" ]]; then
    echo "Skipping $DRIVE (not found)"
    continue
  fi

  echo "Processing $SRC -> $DST"

  # PASS 1 — mirror directories and images
  rsync -a --delete \
    --exclude='.DocumentRevisions-V100' \
    --exclude='.Spotlight-V100' \
    --exclude='.TemporaryItems' \
    --exclude='.Trashes' \
    --exclude='.fseventsd' \
    --exclude='.DS_Store' \
    --exclude='._*' \
    --include='*/' \
    --include='*.jpg' \
    --include='*.jpeg' \
    --include='*.png' \
    --exclude='*' \
    "$SRC/" "$DST/" 2>/dev/null

  # PASS 2 — create placeholders (exclude macOS junk)
  cd "$SRC" || continue

  find . \
    \( -name ".DocumentRevisions-V100" \
    -o -name ".Spotlight-V100" \
    -o -name ".TemporaryItems" \
    -o -name ".Trashes" \
    -o -name ".fseventsd" \) -prune \
    -o -type f ! \( \
      -iname "*.jpg" -o \
      -iname "*.jpeg" -o \
      -iname "*.png" \
    \) \
    ! -name ".DS_Store" \
    ! -name "._*" \
    -print 2>/dev/null \
  | while read -r file; do

    placeholder="$DST/$file.txt"
    mkdir -p "$(dirname "$placeholder")" 2>/dev/null

    if [[ ! -f "$placeholder" ]]; then
      echo "placeholder for $file" > "$placeholder"
    fi

  done

  # PASS 3 — remove orphan placeholders
  cd "$DST" || continue

  find . -type f -name "*.txt" 2>/dev/null | while read -r p; do
    original="${p%.txt}"

    # Skip macOS junk placeholders just in case
    case "$original" in
      */.DS_Store|*/._*) continue ;;
    esac

    if [[ ! -f "$SRC/$original" ]]; then
      rm -f "$p"
    fi
  done

done