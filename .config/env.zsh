#!/usr/bin/env zsh

if [[ -z "${HR:-}" ]]; then
  # shellcheck source=./_functions.zsh
  source "$HOME/.config/_functions.zsh"
fi

ZSHENV_FILE="$HOME/.zshenv"

function configure_env() {
  echo -e "\n${MAGENTA}Configuring environment...${RESET}\n"
  # Let Bash use some of the ZSH configuration
  if [[ ! -L "$HOME/.aliases" ]]; then
    ln -s "$HOME/.zaliases" "$HOME/.aliases"
    _check "Link ~/.aliases"
  else
    _skip "Link ~/.aliases (Exists)"
  fi
  if [[ ! -L "$HOME/.exports" ]]; then
    ln -s "$HOME/.zshenv" "$HOME/.exports"
    _check "Link ~/.exports"
  else
    _skip "Link ~/.exports (Exists)"
  fi

  # Always start with ~/.local
  LOCAL="$HOME/.local"

  # Create ~/.local/bin/sbin if they do not exist
  # Create bin and sbin subdirectories in $LOCAL
  install -d "$LOCAL" -m 755 || err-exit "${WHITE}Create${RESET} $LOCAL"
  install -d "$LOCAL/bin" -m 755 || err-exit "${WHITE}Create${RESET} $LOCAL/bin"
  install -d "$LOCAL/sbin" -m 755 || err-exit "${WHITE}Create${RESET} $LOCAL/sbin"

  # Conditional Symlink to /opt/local if sudo is available
  if can_sudo; then
      OPT_LOCAL="/opt/local"
      # If /opt/local exists but is not a symlink, warn user (optional safety)
      if [[ -e "$OPT_LOCAL" && ! -L "$OPT_LOCAL" ]]; then
        _cross "Link $OPT_LOCAL"
        echo "  ${RED}ERROR:${RESET} $OPT_LOCAL ${RED}exists and is not a symlink. Exiting...${RESET}"
        exit 1
      elif [[ ! -L "$OPT_LOCAL" ]]; then
        echo -e "-- ${YELLOW} Requesting sudo to create symlink for${RESET} $OPT_LOCAL --\n"
        sudo ln -s "$LOCAL" "$OPT_LOCAL"
        echo ""
        _check "Link $OPT_LOCAL"
        # Update LOCAL to point to the symlink target
        LOCAL="$OPT_LOCAL"
      else
        _skip "Link $OPT_LOCAL (Exists)"
      fi
  else
    _skip "Link $OPT_LOCAL (Skipped)"
  fi

  # Export LOCAL for the current session
  export LOCAL

  # Check if the exports are already Present
  if grep -q "^export LOCAL=" "$ZSHENV_FILE" 2>/dev/null && \
    grep -q "^export PATH=\"$LOCAL/bin:$LOCAL/sbin:\"" "$ZSHENV_FILE" 2>/dev/null;
  then
    _skip "Update PATH (Skipped)"
  else
    # Append the exports
    cat >> "$ZSHENV_FILE" << EOF

# dotspot: Local Tool Directory
export LOCAL="$LOCAL"
export PATH="$LOCAL/bin:$LOCAL/sbin:\$PATH"

EOF
    _check "Update PATH"
  fi

  # Make Developer Directory if not Present
  /bin/mkdir -p "$HOME/Developer"
  if grep -q "^DEV_DIR=" "$ZSHENV_FILE" 2>/dev/null; then
    _skip "Set DEV_DIR (Skipped)"
  else
    echo "DEV_DIR=\"\${HOME}/Developer\"" >> "$ZSHENV_FILE"
    _check "Set DEV_DIR"
  fi

  # Set Editor
  if grep -q "^GIT_EDITOR=" "$ZSHENV_FILE" 2>/dev/null; then
    _skip "Set GIT_EDITOR (Skipped)"
  else
    echo "GIT_EDITOR=nano" >> "$ZSHENV_FILE"
    _check "Set GIT_EDITOR"
  fi

  # Set History File
  if grep -q "^HISTFILE=" "$ZSHENV_FILE" 2>/dev/null; then
    _skip "Set HISTFILE (Skipped)"
  else
    echo "HISTFILE=\"\${ZDOTDIR:-\$HOME}/.zsh_history\"" >> "$ZSHENV_FILE"
    _check "Set HISTFILE"
  fi
}

if [[ ! $zsh_eval_context =~ 'file' ]]; then
  configure_env "$@"
fi
