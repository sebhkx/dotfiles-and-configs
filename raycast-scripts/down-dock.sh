#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Down Dock
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

defaults write com.apple.dock tilesize -int 16 && \
defaults write com.apple.dock orientation bottom && \
killall Dock