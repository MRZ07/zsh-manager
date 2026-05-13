# zsh-manager

![Version](https://img.shields.io/badge/release-1.0.0-blue) ![License](https://img.shields.io/badge/license-MIT-green) ![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey)

Your ZSH config, finally under control.

zsh-manager is a small framework that brings structure to your shell configuration. Split your aliases, functions, secrets, and tool setup into focused files. Run the same config on Linux, macOS, and Windows without touching a line. Keep the framework separate from your personal config so you can pull updates without blowing anything up.

No magic. Just organized shell scripts and a loader that knows what order to run them in.

---

## Directory Structure

```
zsh-manager/
├── load.sh                          # Sourceable framework loader
├── .zshrc                           # Standalone entry point (symlinked to ~/.zshrc)
├── run-to-simlink.sh                # Setup script for standalone use
│
├── secrets/                         # API keys & tokens — *.sh gitignored by default
│   ├── common/                      # Loaded on all platforms
│   ├── linux/
│   ├── macos/
│   └── windows/
│
├── preload_configs/                 # Shell initialization (PATH, plugins, tool setup)
│   ├── common/
│   ├── linux/
│   │   └── path.sh
│   ├── macos/
│   │   └── path.sh
│   └── windows/
│       └── path.sh
│
└── modules/                         # Aliases and functions
    ├── common/
    ├── linux/
    ├── macos/
    └── windows/
```

---

## How It Works

### Loading Order

Each section loads `common/` first, then your OS-specific folder. Within each folder, every `*.sh` file is sourced recursively.

| # | Section | What goes here |
|---|---------|---------------|
| 0 | `preload_configs/<os>/path.sh` | Loaded **first**, explicitly — ensures PATH is ready |
| 1 | `secrets/` | API keys, tokens, env vars |
| 2 | `preload_configs/` | Shell plugins, tool init (omz, fnm, zoxide…) |
| 3 | `modules/` | Aliases and functions |

### Ignoring Files

Prefix any file or folder with `#` to skip it without deleting it:

```
modules/common/
├── aliases.sh
├── #old-aliases.sh      ← skipped
└── #deprecated/         ← entire folder skipped
```

### `ZSH_MANAGER_CONFIG_DIR`

Set this before sourcing `load.sh` to point the framework at a different directory for your personal configs. This is how decoupled mode works — your scripts live in your own repo, the framework lives separately and can be updated independently.

---

## Installation

### Standalone

Everything in one place — the framework directory is also your config directory.

```sh
git clone git@github.com:MRZ07/zsh-manager.git ~/.config/zsh-manager
cd ~/.config/zsh-manager && ./run-to-simlink.sh
```

Symlinks `~/.zshrc` → `~/.config/zsh-manager/.zshrc`. Drop scripts into `modules/`, `preload_configs/`, and `secrets/`.

---

### Decoupled — recommended for dotfiles repos

Keep your personal config in your own repo. Pull framework updates without touching your scripts.

**1. Clone the framework:**

```sh
git clone git@github.com:MRZ07/zsh-manager.git ~/.config/zsh-manager
```

**2. Add a loader to your dotfiles:**

```sh
# your-dotfiles/zsh-manager/load-zsh-manager.sh

ZSH_MANAGER_CONFIG_DIR=$(dirname $(realpath $HOME/.zshrc))
ZSH_MANAGER_FRAMEWORK_DIR="${ZSH_MANAGER_FRAMEWORK_DIR:-$HOME/.config/zsh-manager}"

if [[ ! -f "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh" ]]; then
    echo "[zsh-manager] Framework not found at: $ZSH_MANAGER_FRAMEWORK_DIR"
    echo "[zsh-manager] Run: git clone git@github.com:MRZ07/zsh-manager.git $HOME/.config/zsh-manager"
    return 1
fi

source "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh"
```

**3. Source it from your `.zshrc`:**

```sh
source $(dirname $(realpath $HOME/.zshrc))/load-zsh-manager.sh
```

**4. Update the framework any time:**

```sh
git -C ~/.config/zsh-manager pull
```

> **Custom location:** Set `ZSH_MANAGER_FRAMEWORK_DIR` in `~/.zshenv` if the framework lives somewhere other than `~/.config/zsh-manager`.

---

## Secrets

API keys and tokens go in `secrets/`. Every `*.sh` file there is gitignored by default — they can never be accidentally committed.

```
secrets/common/
├── secrets.sh.example   ← tracked template, copy this to get started
├── api-keys.sh          ← your actual values (gitignored)
└── work.sh              ← split by category however makes sense to you
```

First-time setup on a new machine:

```sh
cp secrets/common/secrets.sh.example secrets/common/secrets.sh
# open secrets.sh and fill in your values
```

> **Migrating from `~/.env.sh`:** The framework still loads `~/.env.sh` if it exists, so existing setups keep working. `secrets/` is the preferred approach going forward.

---

## Compatibility

Works alongside Oh-My-Zsh, Prezto, Antigen, Zim, and other ZSH frameworks.

| Platform | Support |
|----------|---------|
| macOS | ✓ |
| Linux | ✓ |
| Windows (WSL, Git Bash, Cygwin, MSYS2) | ✓ |

---

## License

MIT
