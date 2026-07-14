#!/bin/bash
i=1; echo '<?xml version="1.0"?><Chapters><EditionEntry>' > chapters.xml
while read t title; do
  h=${t%%:*}; m=${t#*:}; m=${m%%:*}; s=${t##*:}
  ts=$(printf "%02d:%02d:%02d.000" "$h" "$m" "$s")
  printf '<ChapterAtom><ChapterTimeStart>%s</ChapterTimeStart><ChapterDisplay><ChapterString>%s</ChapterString></ChapterDisplay></ChapterAtom>\n' "$ts" "$title" >> chapters.xml
done < "$1"
echo '</EditionEntry></Chapters>' >> chapters.xml
