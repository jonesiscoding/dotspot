# shellcheck shell=bash

[[ -z "$BREW_BIN" ]] && [[ -f "/opt/homebrew/bin/brew" ]] && BREW_BIN="/opt/homebrew/bin/brew"
[[ -z "$BREW_BIN" ]] && [[ -f "/usr/local/bin/brew" ]] && BREW_BIN="/usr/local/bin/brew"

function _isMacSudo() {
  if [ "$HOME" != "/var/root" ]; then
    if /bin/test -w /var/root; then
      return 0
    fi
  fi

  return 1
}

function install_brew() {
  if _isMacSudo; then
    echo "Installing Homebrew..."
    echo "----------------------------------------------"
    if /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      echo "----------------------------------------------"
      return 0
    else
      echo "----------------------------------------------"
      echo "ERROR: Homebrew installation failed, please see errors above."
      return 1
    fi
  elif [ "$USER" == "root" ]; then
    echo "ERROR: Homebrew cannot install as root. Run  as yourself, with sudo!"
    return 1
  else
    echo "Skipping Homebrew Install (User does not have 'sudo' rights)"
    return 0
  fi
}

function install_brewfile() {
  local BIGLINE
  local BREWFILE

  BIGLINE="-----------------------------------"

  if [[ -z "$BREW_BIN" ]]; then
    echo "ERROR: Cannot install items in .Brewfile.  Homebrew is not installed."
    return 1
  fi

  # shellcheck disable=SC2002
  BREWFILE=$(cat "$HOME/.Brewfile" | xargs)
  if [ -f "$HOME/.Brewfile" ] && [ -n "$BREWFILE" ]; then
    echo "Updating Homebrew bundle..."
    echo $BIGLINE

    if "$BREW_BIN" bundle --global; then
      echo $BIGLINE
      return 0
    else
      echo $BIGLINE
      echo "ERROR: Could not install brew bundle!"
      return 1
    fi
  else
    echo "Skipping Brewfile (not present)"
  fi
}
