# 🚀 configs | automation

A collection of personal configuration (dot)files, `zsh` environment setups, snippets & scripting utilities to eliminate repetitive tasks and streamline daily workflows

---

## 📦 Repository Structure

```
├── .zshrc                    # Shell environment, aliases, and functions
```

```
├── .gitconfig                # GitHub account switching by custom alias
├── .ssh/config               # Add HostNames for ssh identities
```

```
└── raycast-scripts/          # Custom standalone utilities
    └── auto-day-name-date.sh # Dynamic natural language date parser
    └── corner.sh             # use hammerspoon to move mouse to window corner (no need to hunt for it and just drag)
    └── down-dock.sh / left-dock.sh # cos I keep shifting my dock for multi monitors
    └── mirror.sh             # mirror images backup
```

```
├── .hammerspoon
    └── init.lua
    └── modules
        └── capslock.lua        # used with karabiner to turn hold CAPS + UIO JKL M to 456 123 0
                                # numpad cluster [789 456 123 0] for numrow keyboard
        └── auto-hide-apps.lua
        └── current-wattage.lua
        └── drag-to-space.lua
        └── preview-snap.lua
    └── test
        └── watcher.lua
├── karabiner-elements (~/.config/karabiner/assets/complex_modifications)
    └── caps-f18.json           # let karabiner disable caps and let hammerspoon emulate CAPS LOCK & 2nd layer
```

```
├── tampermonkey: custom JavaScript & CSS injections
* Enable Developer Mode & Allow User Scrips
    └── Universal Page Tab Renamer
    └── Download Largest Image & Rename based on URL
    └── Search keyword page by page until term is found
    └── Arrow left/right for previous & next page
```

## Automator

- VCS
- ImageMagick

## jupyter-notebook

### PDF Overlay on A4 Size # space saving prints for shipping labels

- reportlab & PyPDF2

1. Generate blank A4 pdf
2. Overlay (smaller pdf) on A4 (default coordinate 0,0 is bottom left) -- to work on top left alignment
