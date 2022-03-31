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
├── init.sh                          # Decoupled entry point
├── .zshrc                           # Standalone entry point (symlinked to ~/.zshrc)
├── run-to-simlink.sh                # Setup script for standalone use
│
└── profiles/                        # Configuration profiles
    ├── default/                     # Base profile (example)
    │   ├── common/                  # Loaded on all platforms
    │   │   ├── secrets/             # (organizational convention)
    │   │   ├── preload_configs/
    │   │   └── modules/
    │   ├── linux/                   # Loaded on Linux only
    │   ├── macos/                   # Loaded on macOS only
    │   └── windows/                 # Loaded on Windows only
    ├── private/                     # Your private profile
    │   ├── common/
    │   ├── linux/
    │   ├── macos/
    │   └── windows/
    └── work/                        # Your work profile
        ├── common/
        ├── linux/
        ├── macos/
        └── windows/
```

---

## How It Works

### Loading Order

Each profile loads in this order:

| # | Directory | What goes here |
|---|-----------|---------------|
| 1 | `common/` | Cross-platform config (aliases, functions, secrets) |
| 2 | `linux/`, `macos/`, or `windows/` | OS-specific overrides (only the matching OS) |

Within each directory, every `*.sh` file is sourced recursively (lexicographic sort — use `00-`, `10-` prefixes to control order). No section ordering is enforced — organize files inside `common/` however you like (e.g. `secrets/`, `preload_configs/`, `modules/` are purely conventional).

### Profiles

`ZSH_MANAGER_PROFILES` is **required** — at least one profile must be specified.

```sh
# Load only default
ZSH_MANAGER_PROFILES=(default)

# Load default, then private, then work (in order)
ZSH_MANAGER_PROFILES=(default private work)

# Load default + ALL other profiles alphabetically
ZSH_MANAGER_PROFILES=(*)
```

Profiles are additive — later profiles can override aliases, functions, and env vars from earlier ones.

### Ignoring Files

Prefix any file or folder with `#` to skip it without deleting it:

```
profiles/default/common/modules/
├── aliases.sh
├── #old-aliases.sh      ← skipped
└── #deprecated/         ← entire folder skipped
```

### `ZSH_MANAGER_CONFIG_DIR`

Set this before sourcing `load.sh` (or `init.sh`) to point the framework at a different directory for your personal configs. This is how decoupled mode works — your scripts live in your own repo, the framework lives separately and can be updated independently.

---

## Installation

### Standalone

Everything in one place — the framework directory is also your config directory.

```sh
git clone git@github.com:MRZ07/zsh-manager.git ~/.config/zsh-manager
cd ~/.config/zsh-manager && ./run-to-simlink.sh
```

Symlinks `~/.zshrc` → `~/.config/zsh-manager/.zshrc`. Drop scripts into `profiles/default/common/` (or `profiles/default/linux/`, `profiles/default/macos/`, `profiles/default/windows/` for OS-specific files).

Add more profiles by creating directories under `profiles/` (e.g. `profiles/work/`) and enabling them:

```sh
# In your .zshrc before the symlink, or in a local config file
ZSH_MANAGER_PROFILES=(default work)
```

---

### Decoupled — recommended for dotfiles repos

Keep your personal config in your own repo. Pull framework updates without touching your scripts.

**1. Clone the framework:**

```sh
git clone git@github.com:MRZ07/zsh-manager.git ~/.config/zsh-manager
```

**2. Create your personal config directory with profiles:**

```sh
mkdir -p ~/my-dotfiles/zsh-manager/profiles/{default,private,work}/{common,linux,macos,windows}
```

**3. Add a loader to your dotfiles:**

```sh
# your-dotfiles/zsh-manager/load-zsh-manager.sh

ZSH_MANAGER_CONFIG_DIR=$(dirname $(realpath $HOME/.zshrc))
ZSH_MANAGER_FRAMEWORK_DIR="${ZSH_MANAGER_FRAMEWORK_DIR:-$HOME/.config/zsh-manager}"
ZSH_MANAGER_PROFILES=(default private work)   # or (*) for all

if [[ ! -f "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh" ]]; then
    echo "[zsh-manager] Framework not found at: $ZSH_MANAGER_FRAMEWORK_DIR"
    echo "[zsh-manager] Run: git clone git@github.com:MRZ07/zsh-manager.git $HOME/.config/zsh-manager"
    return 1
fi

source "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh"
```

**4. Source it from your `.zshrc`:**

```sh
source $(dirname $(realpath $HOME/.zshrc))/load-zsh-manager.sh
```

**5. Update the framework any time:**

```sh
git -C ~/.config/zsh-manager pull
```

> **Custom location:** Set `ZSH_MANAGER_FRAMEWORK_DIR` in `~/.zshenv` if the framework lives somewhere other than `~/.config/zsh-manager`.

---

## Secrets

API keys and tokens can go anywhere inside your profile's `common/`, `linux/`, `macos/`, or `windows/` directories. Every `*.sh` file inside `profiles/` is gitignored by default — secrets can never be accidentally committed.

```
profiles/default/common/
├── secrets.sh.example   ← tracked template, copy this to get started
├── api-keys.sh          ← your actual values (gitignored)
└── modules/
    └── aliases.sh       ← also gitignored
```

First-time setup on a new machine:

```sh
cp profiles/default/common/secrets.sh.example profiles/default/common/secrets.sh
# open secrets.sh and fill in your values
```

> **Migrating from `~/.env.sh`:** The framework no longer loads `~/.env.sh`. Use the `secrets/` convention inside your profile instead.

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