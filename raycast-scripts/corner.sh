#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Corner
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ↘️

osascript '
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
end tell
'
sleep 0.1

exec >/dev/null 2>&1

HS="/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs"

"$HS" -c '
local w = hs.window.focusedWindow()
if not w then return end

local f = w:frame()
hs.mouse.absolutePosition({
    x = f.x + f.w - 1,
    y = f.y + f.h - 1
})
'