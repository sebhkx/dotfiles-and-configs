#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Left Dock
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

defaults write com.apple.dock orientation left; killall Dock

