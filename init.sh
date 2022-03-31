# ZSH-Manager decoupled entrypoint.
#
# Source this from your personal .zshrc when your config lives outside the
# framework repo (e.g. in a separate dotfiles/macos-config repo).
#
# Usage — in your ~/.zshrc (or a file it sources):
#
#   ZSH_MANAGER_CONFIG_DIR=/path/to/your/personal/zsh-manager
#   ZSH_MANAGER_PROFILES=(private work)
#   source ~/.config/zsh-manager/init.sh
#
# ZSH_MANAGER_CONFIG_DIR  — directory containing your profiles/,
#                            and zsh-manager.config.sh.
#                            Defaults to the directory of the file sourcing this
#                            script (i.e. the personal config dir).
#
# ZSH_MANAGER_PROFILES    — array of profile names to load from profiles/.
#                            Can also be set inside zsh-manager.config.sh in your
#                            config dir — that file is sourced before load.sh runs.
#                            Use (*) to load all profiles alphabetically after default.
#
# ZSH_MANAGER_FRAMEWORK_DIR — override the framework location (default: ~/.config/zsh-manager).

ZSH_MANAGER_FRAMEWORK_DIR="${ZSH_MANAGER_FRAMEWORK_DIR:-$(dirname $(realpath ${(%):-%x}))}"

# If ZSH_MANAGER_CONFIG_DIR is not already set by the caller, derive it from
# the real path of the sourcing file (the personal .zshrc or bridge file).
if [[ -z "$ZSH_MANAGER_CONFIG_DIR" ]]; then
    ZSH_MANAGER_CONFIG_DIR="$(dirname $(realpath $HOME/.zshrc))"
fi

# Load profile selection from personal config dir if not already set by caller
if [[ -z "${ZSH_MANAGER_PROFILES+x}" ]]; then
    local _cfg="$ZSH_MANAGER_CONFIG_DIR/zsh-manager.config.sh"
    [[ -f "$_cfg" ]] && source "$_cfg"
    unset _cfg
fi

if [[ ! -f "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh" ]]; then
    echo "[zsh-manager] Framework not found at: $ZSH_MANAGER_FRAMEWORK_DIR"
    echo "[zsh-manager] Clone it: git clone git@github.com:MRZ07/zsh-manager.git $HOME/.config/zsh-manager"
    echo "[zsh-manager] Or set ZSH_MANAGER_FRAMEWORK_DIR in ~/.zshenv for a custom location."
    return 1
fi

source "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh"