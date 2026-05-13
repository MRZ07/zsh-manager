# ZSH-Manager standalone entry point.
# ~/.zshrc is symlinked here via run-to-simlink.sh for standalone use.
# For decoupled usage (personal config in a separate repo), source load.sh
# directly with ZSH_MANAGER_CONFIG_DIR pointing to your config directory.
ZSH_MANAGER_FRAMEWORK_DIR=$(dirname $(realpath $HOME/.zshrc))
source "$ZSH_MANAGER_FRAMEWORK_DIR/load.sh"
