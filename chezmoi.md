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

- Open a new zsh shell.
```
chezmoi init

chezmoi add ~/.zshrc
chezmoi add ~/.gitconfig
chezmoi add ~/.ssh/config # don't commit secrets or keys!
chezmoi add ~/.hammerspoon # etc paths
```
- 👉 Verify paths
```
chezmoi managed
```

- 👉 Configure VS code as editor
```
chezmoi config set editor "code --wait"
```

- 👉 Alt: Open the entire source directory as a project
```
code "$(chezmoi source-path)"
```
```
cd "$(chezmoi source-path)"
code .         # use Git
```

`chezmoi apply` installs missing Homebrew packages from `Brewfile` on macOS
when the `Brewfile` changes. It uses `--no-upgrade`; package upgrades stay
manual.

## Daily use

Pull and apply the latest committed dotfiles:

```sh
chezmoi update --verbose
```

Preview before applying: **diff + apply**
*be careful with recursive directories
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

Edit source dotfiles directly *through chezmoi* 🙏:

```sh
chezmoi edit ~/.zshrc
chezmoi edit --apply ~/.zshrc # diff + apply built-in
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
