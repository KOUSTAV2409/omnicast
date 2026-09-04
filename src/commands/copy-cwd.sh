#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Copy Working Directory
# @raycast.mode silent
# @raycast.icon 📁
# @raycast.packageName Files
# @raycast.description Copy $PWD to the clipboard

pwd | tr -d '\n' | wl-copy
