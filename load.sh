# ZSH-Manager Framework Loader
# Sourceable from external configs. Set ZSH_MANAGER_CONFIG_DIR before sourcing
# to load modules/preload_configs/secrets from a personal config directory.
#
# Standalone use: source via .zshrc (handled by run-to-simlink.sh)
# Decoupled use:
#   ZSH_MANAGER_CONFIG_DIR=/path/to/personal/config
#   source ~/.config/zsh-manager/load.sh

# Locate this file — works when sourced in zsh
ZSH_MANAGER_FRAMEWORK_DIR="${ZSH_MANAGER_FRAMEWORK_DIR:-$(dirname $(realpath ${(%):-%x}))}"

# Config dir: where modules/, preload_configs/, secrets/ live.
# Defaults to framework dir for standalone use.
ZSH_MANAGER_CONFIG_DIR="${ZSH_MANAGER_CONFIG_DIR:-$ZSH_MANAGER_FRAMEWORK_DIR}"

# Detect OS
_ZSH_MANAGER_OS_FOLDER=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    _ZSH_MANAGER_OS_FOLDER="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    _ZSH_MANAGER_OS_FOLDER="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    _ZSH_MANAGER_OS_FOLDER="windows"
fi

# Source all .sh files under a directory tree.
# - Sorts by full path (lexicographic), so NN- numeric prefixes control order within each dir.
# - Skips any file or directory whose name starts with #.
# - (N) = nullglob: safe when directory is empty or missing.
# - (.) = regular files only (no dirs, no symlinks to dirs).
_zsh_manager_load_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || return
    local script
    for script in "$dir"/**/*.sh(N.); do
        # Skip files inside #-prefixed directories
        [[ "$script" == *"/#"* ]] && continue
        # Skip #-prefixed files
        [[ "${script:t}" == "#"* ]] && continue
        source "$script"
    done
}

# Load common + OS subfolders under a section directory (used for secrets and preload_configs)
_zsh_manager_load_section() {
    local base="$1"
    _zsh_manager_load_dir "$base/common"
    [[ -n "$_ZSH_MANAGER_OS_FOLDER" ]] && _zsh_manager_load_dir "$base/$_ZSH_MANAGER_OS_FOLDER"
}

# Load order:
# 0. preload_configs/<os>/path.sh — PATH must be set before anything else runs
# 1. secrets/                     — env vars and API keys, no external dependencies
# 2. preload_configs/             — path, shell plugins, tool init (omz, fnm, etc.)
# 3. modules/common/              — universal aliases and functions
# 4. modules/profiles/<profile>/  — per-profile aliases (loaded if ZSH_MANAGER_PROFILES is set)
# 5. modules/<os>/                — OS-specific aliases and functions

# Step 0: explicit early path setup (same file will be sourced again in step 2 — harmless due to fnm guard)
[[ -n "$_ZSH_MANAGER_OS_FOLDER" ]] && {
    _ZSH_MANAGER_PATH_SH="${ZSH_MANAGER_CONFIG_DIR}/preload_configs/${_ZSH_MANAGER_OS_FOLDER}/path.sh"
    [[ -f "$_ZSH_MANAGER_PATH_SH" ]] && source "$_ZSH_MANAGER_PATH_SH"
    unset _ZSH_MANAGER_PATH_SH
}

_zsh_manager_load_section "${ZSH_MANAGER_CONFIG_DIR}/secrets"
_zsh_manager_load_section "${ZSH_MANAGER_CONFIG_DIR}/preload_configs"

# Step 3: universal modules
_zsh_manager_load_dir "${ZSH_MANAGER_CONFIG_DIR}/modules/common"

# Step 4: profile modules — only loaded when a profile is listed in ZSH_MANAGER_PROFILES
local _profile
for _profile in "${ZSH_MANAGER_PROFILES[@]:-}"; do
    [[ -n "$_profile" ]] || continue
    _zsh_manager_load_dir "${ZSH_MANAGER_CONFIG_DIR}/modules/profiles/$_profile"
done
unset _profile

# Step 5: OS-specific modules
[[ -n "$_ZSH_MANAGER_OS_FOLDER" ]] && \
    _zsh_manager_load_dir "${ZSH_MANAGER_CONFIG_DIR}/modules/$_ZSH_MANAGER_OS_FOLDER"

# Legacy: load ~/.env.sh if it exists (deprecated — use secrets/ instead)
[[ -f "$HOME/.env.sh" ]] && source "$HOME/.env.sh"

# Clean up helpers to avoid polluting the shell environment
unset _ZSH_MANAGER_OS_FOLDER
unfunction _zsh_manager_load_dir _zsh_manager_load_section
