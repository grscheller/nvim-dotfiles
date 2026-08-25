## Setup XDG Desktop folder locations
#
# grscheller/nvim-dotfiles uses XDG names in its setup scripts.
#
# - defaults to standard locations if not already defined
#   - can override in shell for multiple configs to exist
#   - nvim on LINUX & Windows will honor these when exported
#     - will use platform dependent defaults when not
#   - nvim on Windows is a native windows app
#     - nvimInstall need to override XDG names with equivalent Windows locations
#       - default Windows locations already exist
#       - their ACL's are not the user's to change
# - tries to ensure XDG directories exist
# - XDG names can be overridden for multiple configurations to coexist
#   - untested so far on Windows
#
# shellcheck shell=sh

if test "$OS" = Windows_NT
then
    # Window 11
    _local_app_data="$(cygpath -u "$LOCALAPPDATA")"
    : "${WIN_LOCAL_APP_DATA:=$_local_app_data}"
    : "${WIN_CACHE_HOME:=$_local_app_data/Temp}"
    unset _local_app_data
    : "${XDG_CONFIG_HOME:=$HOME/.config}"
    : "${XDG_DATA_HOME:=$HOME/.local/share}"
    : "${XDG_STATE_HOME:=$HOME/.local/state}"
    : "${XDG_CACHE_HOME:=$HOME/.cache}"
    # shellcheck disable=SC2034  # consumed by nvimInstall after sourcing
    nvim_data_dir=nvim-data
else
    # Linux
    : "${WIN_LOCAL_APP_DATA:=}"
    : "${WIN_CACHE_HOME:=}"
    : "${XDG_CONFIG_HOME:=$HOME/.config}"
    : "${XDG_DATA_HOME:=$HOME/.local/share}"
    : "${XDG_STATE_HOME:=$HOME/.local/state}"
    : "${XDG_CACHE_HOME:=$HOME/.cache}"
    # shellcheck disable=SC2034  # consumed by nvimInstall after sourcing
    nvim_data_dir=nvim
fi

export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
export WIN_LOCAL_APP_DATA WIN_CACHE_HOME

ensure_dir "$XDG_CONFIG_HOME" >&2
chmod 0755 "$XDG_CONFIG_HOME"
ensure_dir "$XDG_DATA_HOME" >&2
chmod 0755 "$XDG_DATA_HOME"
ensure_dir "$XDG_STATE_HOME" >&2
chmod 0755 "$XDG_STATE_HOME"
ensure_dir "$XDG_CACHE_HOME" >&2
chmod 0755 "$XDG_CACHE_HOME"
