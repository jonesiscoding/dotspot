#!/usr/bin/env zsh

function configure_ssh() {
  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    /usr/bin/ssh-keygen -t ed25519
  fi

  eval "$(ssh-agent -s)"
  /bin/mkdir -p "$HOME/.ssh/config.d"
}

if [[ ! $zsh_eval_context =~ 'file' ]]; then
  configure_ssh "$@"
fi
