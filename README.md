# dotfiles

My personal Apple Silicon Mac setup, managed with nix-darwin, Home Manager, and Homebrew.

This repository started from [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) and is now maintained independently for my own machines and workflow.

## What it manages

- macOS defaults for appearance, keyboard repeat, Dock, Finder, window tiling, and trackpad
- Homebrew formulae, casks, and Mac App Store applications
- command-line tools, fonts, Zsh, Git, and language runtimes
- Neovim, tmux, Herdr, VS Code, CotEditor, Squirrel, and selected application preferences
- Karabiner keyboard layers and utility scripts
- Pi extensions, skills, settings, and shared agent instructions

The main configuration targets:

- user: `qianwei`
- host label: `mac`
- architecture: `aarch64-darwin`

## Install

Review `configuration.nix` before applying this repository to an existing Mac.

> [!WARNING]
> `homebrew.onActivation.cleanup = "zap"` removes every Homebrew formula and cask not declared in `configuration.nix`, including associated cask files.

```sh
git clone https://github.com/JokerQianwei/dotfiles.git
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh`:

1. installs Determinate Nix when needed
2. links the checkout to `~/.dotfiles`
3. checks the configured macOS username
4. runs the first `darwin-rebuild switch`

For a dry validation after Nix is installed:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

Apply later changes with:

```sh
./rebuild.sh
```

## Adapting the repository

Change these values before using the configuration on another machine:

- `flake.nix`: the `user` value
- `flake.nix`, `bootstrap.sh`, and `rebuild.sh`: the `mac` host label
- `configuration.nix`: `nixpkgs.hostPlatform`
- `home.nix`: the Git name and email

The username is threaded through the system and Home Manager configuration. `bootstrap.sh` can rewrite it interactively when it differs from the current macOS user.

## Configuration model

`home/` contains the source files. Home Manager uses `mkOutOfStoreSymlink` to link them into the home directory, so editing a linked file in the repository changes the live configuration immediately.

Run `./rebuild.sh` after changing Nix modules, packages, system defaults, or file declarations. A rebuild is usually unnecessary after editing an already linked application config.

Key files:

| Path | Purpose |
|---|---|
| `flake.nix` | Inputs, user, and `mac` darwin configuration |
| `configuration.nix` | macOS defaults, Homebrew, and Mac App Store applications |
| `home.nix` | User packages, shell, Git, runtimes, prompt, and managed links |
| `home/` | Application configs, scripts, Pi resources, and agent instructions |
| `bootstrap.sh` | First installation |
| `rebuild.sh` | Subsequent activation |

## Shell and development tools

Home Manager configures:

- Zsh with shared history, autosuggestions, syntax highlighting, and a small alias set
- fzf, ripgrep, fd, jq, and GitHub CLI
- mise with pinned Go, Node.js, and Python versions
- 1Password SSH agent integration

## Editors and terminal

Neovim uses lazy.nvim, the Nord theme, built-in LSP, Oil, Snacks, Neogit, Gitsigns, Which-key, and Markdown rendering. The first launch downloads lazy.nvim and plugins from GitHub.

Both tmux and Herdr use a backtick prefix and provide vi-oriented pane and copy workflows.

VS Code settings and pinned extension versions are stored under `home/.config/vscode`. Restore the extensions with:

```sh
install-vscode-extensions
```

CotEditor is the default application for common text-file formats.

## Application preferences

Only preferences that are useful and safe to publish are tracked.

- Bob, Caffeine, Maccy, and Mos settings are restored with `restore-app-preferences`.
- Snipaste, GitHub CLI, Herdr, and Karabiner use linked configuration files.
- Squirrel links the public Rime schema, fuzzy-pinyin, and theme overrides. These overrides expect rime-ice to be installed separately; generated state and personal phrases remain local.
- `export-logi-options-plus` extracts a reviewed, sanitized Logi Options+ snapshot. It is for inspection and manual recovery because Logi Options+ has no stable public import interface.

Karabiner also maps `Cmd+Option+V` and `Cmd+Shift+V` in Kitty to `pi-paste-image-safe2`. The script uploads a clipboard image through the local SSH alias `safe2`, copies the remote path, and pastes it into Kitty. Host details and credentials stay in the local SSH configuration.

## Pi and agent resources

Pi is installed through the `pi-coding-agent` Homebrew formula. Home Manager links only repository-authored or reviewed resources:

- `~/.pi/agent/extensions`
- selected Pi settings and local packages
- shared skills under `~/.agents/skills` for Pi, Codex, and Claude
- `home/AGENTS.md` for Pi, Codex, and Claude

The tracked Pi setup includes an edit-tool router, retry handling, fixed third-party package versions, and the local `pi-herdr-btw` package. Third-party packages execute with the current user's permissions; review `home/.pi/agent/settings.json` before enabling or updating them.

Run `/reload` in Pi after changing extensions, skills, or settings.

The repository does not track Pi authentication, model definitions, MCP credentials, sessions, trust state, caches, or downloaded npm and Git package trees.

## Data intentionally excluded

The repository also excludes:

- SSH, cloud, npm, and Git credentials
- `.env` files, private keys, and certificates
- application accounts, API keys, histories, and device databases
- Herdr runtime logs and sessions
- Snipaste capture history
- local validation evidence under `.no-mistakes/`

## Contributing

This is a personal configuration repository. Pull requests and feature requests are not accepted. See `CONTRIBUTING.md` for the issue policy.

## License

MIT No Attribution. See `LICENSE`.

`home/Library/Rime/squirrel.custom.yaml` is derived from
[rime-squirrel-macos-color-scheme](https://github.com/lonr/rime-squirrel-macos-color-scheme)
and remains licensed under GPL-3.0-only.
