# ZSH-Manager Framework Loader
# Requires ZSH_MANAGER_PROFILES with at least one profile name.
#
# Standalone use:
#   ZSH_MANAGER_PROFILES=(default)
#   source ~/.config/zsh-manager/load.sh
#
# Decoupled use:
#   ZSH_MANAGER_CONFIG_DIR=/path/to/personal/config
#   ZSH_MANAGER_PROFILES=(default work)
#   source ~/.config/zsh-manager/load.sh
#
# Profiles:
#   ZSH_MANAGER_PROFILES=(default)           # load only default
#   ZSH_MANAGER_PROFILES=(default work)      # load default, then work
#   ZSH_MANAGER_PROFILES=(*)                 # load default + all other profiles

# Locate this file — works when sourced in zsh
ZSH_MANAGER_FRAMEWORK_DIR="${ZSH_MANAGER_FRAMEWORK_DIR:-$(dirname $(realpath ${(%):-%x}))}"

# Config dir: where profiles/ lives.
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
# - Sorts by full path (lexicographic), so NN- numeric prefixes control order.
# - Skips any file or directory whose name starts with #.
# - (N) = nullglob: safe when directory is empty or missing.
# - (.) = regular files only (no dirs, no symlinks to dirs).
_zsh_manager_load_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || return
    local script
    for script in "$dir"/**/*.sh(N.); do
        [[ "$script" == *"/#"* ]] && continue
        [[ "${script:t}" == "#"* ]] && continue
        source "$script"
    done
}

# Load a single profile: OS path.sh first, then common/, then OS-specific
_zsh_manager_load_profile() {
    local profile="$1"
    local base="${ZSH_MANAGER_CONFIG_DIR}/profiles/$profile"
    [[ -d "$base" ]] || return

    # Keep old behavior: load OS path.sh before OMZ/common scripts.
    # The same file may be sourced again during recursive OS load; path.sh
    # should be written idempotent.
    if [[ -n "$_ZSH_MANAGER_OS_FOLDER" ]]; then
        local path_sh="$base/$_ZSH_MANAGER_OS_FOLDER/path.sh"
        [[ -f "$path_sh" ]] && source "$path_sh"
    fi

    _zsh_manager_load_dir "$base/common"
    [[ -n "$_ZSH_MANAGER_OS_FOLDER" ]] && _zsh_manager_load_dir "$base/$_ZSH_MANAGER_OS_FOLDER"
}

# Require at least one profile
if [[ -z "${ZSH_MANAGER_PROFILES[*]:-}" ]]; then
    echo "[zsh-manager] Error: ZSH_MANAGER_PROFILES is empty or not set."
    echo "[zsh-manager] Set at least one profile, e.g.: ZSH_MANAGER_PROFILES=(default)"
    return 1
fi

# Determine which profiles to load
typeset -a _zsh_manager_profiles_to_load

if [[ "${ZSH_MANAGER_PROFILES[*]}" == *"*"* ]]; then
    # Load default first, then all other profiles alphabetically
    _zsh_manager_profiles_to_load=(default)
    local profile_dir
    for profile_dir in "${ZSH_MANAGER_CONFIG_DIR}"/profiles/*(/N); do
        local name="${profile_dir:t}"
        [[ "$name" == "default" ]] && continue
        [[ "$name" == "#"* ]] && continue
        _zsh_manager_profiles_to_load+=("$name")
    done
else
    _zsh_manager_profiles_to_load=("${ZSH_MANAGER_PROFILES[@]}")
fi

# Load each profile in order
local _profile
for _profile in "${_zsh_manager_profiles_to_load[@]}"; do
    [[ -n "$_profile" ]] || continue
    _zsh_manager_load_profile "$_profile"
done
unset _profile _zsh_manager_profiles_to_load

# Clean up helpers
unset _ZSH_MANAGER_OS_FOLDER
unfunction _zsh_manager_load_dir _zsh_manager_load_profile
