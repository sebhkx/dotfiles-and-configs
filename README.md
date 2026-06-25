# 🚀 Dotfiles & Script

A collection of personal configuration files, `zsh` environment setups, and custom scripting utilities engineered to eliminate repetitive tasks and streamline daily macOS workflows.

---

## 📦 Repository Structure

```text
├── .zshrc                    # Shell environment, aliases, and functions
└── Raycast scripts/          # Custom standalone utilities
    └── auto-day-name-date.sh # Dynamic natural language date parser
    └── corner.sh             # use hammerspoon to move mouse to window corner (no need to hunt for it and just drag)
    └── down-dock.sh / left-dock.sh # cos I keep shifting my dock for multi monitors
    └── mirror.sh             # mirror images backup
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
    └── caps-f18.json
```

## Bootstrapping chezmoi

```sh
brew install chezmoi
chezmoi init --apply \
    --promptString machineName=<name> \
    https://github.com/sebhkx/dotfiles-and-scripts.git
```

`machineName` becomes the macOS hostname and defaults to the current one. The answer
persists in `~/.config/chezmoi/chezmoi.toml`, so rerunning `chezmoi init` won't ask
again.

Git identity follows the directory: repos under `~/canvas/work/` use the work email
and repos under `~/canvas/personal/` use the personal one.

Open a new zsh shell.

`chezmoi apply` installs missing Homebrew packages from `Brewfile` on macOS
when the `Brewfile` changes. It uses `--no-upgrade`; package upgrades stay
manual.

## Daily use

Pull and apply the latest committed dotfiles:

```sh
chezmoi update --verbose
```

Preview before applying:

```sh
chezmoi git pull -- --autostash --rebase
chezmoi diff
chezmoi apply --verbose
```

Check local package drift:

```sh
brew bundle check --no-upgrade --file "$(chezmoi source-path)/Brewfile" --verbose
brew outdated --greedy
brew bundle cleanup --file "$(chezmoi source-path)/Brewfile"
```

Edit source dotfiles directly:

```sh
chezmoi edit --apply ~/.zshrc
```

Import a live file back into source:

```sh
chezmoi add ~/.zshrc
```

Re-import every drifted managed file at once:

```sh
chezmoi re-add
```

Commit from the source repo:

```sh
chezmoi cd
git status --short
git add -A
git commit -m "Update dotfiles"
git push
```
