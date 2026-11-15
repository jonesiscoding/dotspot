#!/usr/bin/env zsh

function configure_ssh() {
  echo -e "\n${MAGENTA}Configuring SSH Key...${RESET}\n"

  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    /usr/bin/ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519"
  fi

  eval "$(ssh-agent -s)"
  /bin/mkdir -p "$HOME/.ssh/config.d"
}

if [[ ! $zsh_eval_context =~ 'file' ]]; then
  configure_ssh "$@"
fi
