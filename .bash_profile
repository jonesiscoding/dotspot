# shellcheck shell=bash

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	export BASH_COMPLETION_COMPAT_DIR
  # shellcheck disable=SC1091
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
	source /etc/bash_completion;
fi;

# Use ZSH Aliases (requires ZSH specific aliases to be handled correctly in .zaliases)
  # shellcheck disable=SC1091
[[ -e ".aliases" ]] && source .aliases
  # shellcheck disable=SC1091
[[ -e ".aliases.local" ]] && source .aliases.local

# Use ZSH Environment variables
if [[ -e ".exports" ]]; then
  set -a
  # shellcheck disable=SC1091
  source .exports
  set +a
fi

# shellcheck disable=SC1091
[[ -e ".exports.local" ]] && source .exports.local
