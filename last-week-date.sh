#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Auto Day Date
# @raycast.commandName day-auto-week-date
# @raycast.mode silent
# @raycast.packageName Date Utilities

# @raycast.argument1 { "type": "text", "placeholder": "mon - sun | last / next | last last | next next .."}
# Optional parameters:
# @raycast.icon 📅

FORMAT="+%Y/%m/%d"

ARG=$(echo "$1" | tr '[:upper:]' '[:lower:]')

copy() {
  osascript -e "set the clipboard to \"$1\""
}

weekday_offset() {
  case "$1" in
    mon) echo 0 ;;
    tue) echo 1 ;;
    wed) echo 2 ;;
    thu) echo 3 ;;
    fri) echo 4 ;;
    sat) echo 5 ;;
    sun) echo 6 ;;
    *) echo "" ;;
  esac
}

# count modifiers
LAST_COUNT=$(echo "$ARG" | grep -o "last" | wc -l | xargs)
NEXT_COUNT=$(echo "$ARG" | grep -o "next" | wc -l | xargs)

CLEAN=$(echo "$ARG" | sed -E 's/(last|next)//g' | xargs)

# net week shift
WEEK_SHIFT=$(( NEXT_COUNT - LAST_COUNT ))

# anchor: this week's Monday
TODAY_EPOCH=$(date +%s)
TODAY_WEEKDAY=$(date +%u)
MONDAY_EPOCH=$(( TODAY_EPOCH - ((TODAY_WEEKDAY - 1) * 86400) ))

get_date() {
  local day_offset="$1"
  local week_shift="$2"

  local total_days=$((week_shift * 7 + day_offset))
  local target_epoch=$((MONDAY_EPOCH + total_days * 86400))

  date -r "$target_epoch" "$FORMAT"
}

case "$CLEAN" in
  range)
    START_EPOCH=$((MONDAY_EPOCH + WEEK_SHIFT * 7 * 86400))
    START=$(date -r "$START_EPOCH" "$FORMAT")
    END=$(date -r $((START_EPOCH + 6 * 86400)) "$FORMAT")
    copy "$START - $END"
    ;;

  *)
    OFFSET=$(weekday_offset "$CLEAN")

    if [ -z "$OFFSET" ]; then
      exit 0
    fi

    RESULT=$(get_date "$OFFSET" "$WEEK_SHIFT")
    copy "$RESULT"
    ;;
esac
