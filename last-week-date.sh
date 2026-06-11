## Raycast script for copying to clipboard last day's date into clipboard
## if input yesterday's day, result will be the day from last week

#!/bin/bash 


# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Smart Last Week Date
# @raycast.commandName last-week-date
# @raycast.mode compact
# @raycast.argument1 { "type": "text", "placeholder": "mon | tue | wed | thu | fri | sat | sun | range" }

FORMAT="%Y/%m/%d"
ARG=$(echo "$1" | tr '[:upper:]' '[:lower:]')
weekday_num() {
  case "$1" in
    mon) echo 1 ;;
    tue) echo 2 ;;
    wed) echo 3 ;;
    thu) echo 4 ;;
    fri) echo 5 ;;
    sat) echo 6 ;;
    sun) echo 7 ;;
  esac
}

get_date() {
  TARGET="$1"
  TODAY=$(date +%u)
  TARGET_NUM=$(weekday_num "$TARGET")
  DIFF=$((TODAY - TARGET_NUM))
  if [ "$DIFF" -gt 1 ]; then
    date -v-"$TARGET" +"$FORMAT"
  else
    date -v-"$TARGET" -v-1w +"$FORMAT"
  fi
}

copy_to_clipboard() {
  RESULT="$1"
  osascript -e "set the clipboard to \"$RESULT\""
}

case "$ARG" in
  mon|tue|wed|thu|fri|sat|sun)
    RESULT=$(get_date "$ARG")
    copy_to_clipboard "$RESULT"
    ;;
  range)
    START=$(get_date mon)
    END=$(get_date sun)
    RESULT="$START - $END"
    copy_to_clipboard "$RESULT"
    ;;
  *)
esac
